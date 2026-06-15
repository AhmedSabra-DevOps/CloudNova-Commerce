#!/bin/bash
set -eux

apt update -y
apt install -y docker.io docker-compose-v2 python3 curl

systemctl enable docker
systemctl start docker

# Add swap for Elasticsearch / Java stability
if [ ! -f /swapfile ]; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

mkdir -p /opt/cloudnova
cd /opt/cloudnova

cat > /opt/cloudnova/docker-compose.yml <<'YAML'
services:
  db-products:
    image: mongo:6
    container_name: cloudnova-db-products
    restart: unless-stopped

  db-users:
    image: postgres:15
    container_name: cloudnova-db-users
    restart: unless-stopped
    environment:
      POSTGRES_DB: users
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres

  db-cart:
    image: redis:7
    container_name: cloudnova-db-cart
    restart: unless-stopped

  search-engine:
    image: elasticsearch:7.17.10
    container_name: cloudnova-search-engine
    restart: unless-stopped
    environment:
      discovery.type: single-node
      ES_JAVA_OPTS: "-Xms128m -Xmx128m"
    ports:
      - "9200:9200"

  products-service:
    image: ahmedsabra/cloudnova-products-service:latest
    container_name: cloudnova-products-service
    restart: unless-stopped
    depends_on:
      - db-products
    environment:
      MONGO_URL: mongodb://db-products:27017/products
    ports:
      - "5000:5000"
    networks:
      default:
        aliases:
          - products-api

  users-service:
    image: ahmedsabra/cloudnova-users-service:latest
    container_name: cloudnova-users-service
    restart: unless-stopped
    depends_on:
      - db-users
    environment:
      DATABASE_URL: postgresql://postgres:postgres@db-users:5432/users
    ports:
      - "9090:9090"
    networks:
      default:
        aliases:
          - users-api

  cart-service:
    image: ahmedsabra/cloudnova-cart-service:latest
    container_name: cloudnova-cart-service
    restart: unless-stopped
    depends_on:
      - db-cart
    environment:
      REDIS_HOST: db-cart
      REDIS_PORT: 6379
      JAVA_TOOL_OPTIONS: "-Xms64m -Xmx160m"
    ports:
      - "8080:8080"
    networks:
      default:
        aliases:
          - cart-api

  search-service:
    image: ahmedsabra/cloudnova-search-service:latest
    container_name: cloudnova-search-service
    restart: unless-stopped
    depends_on:
      - search-engine
    environment:
      ELASTIC_URL: http://search-engine:9200
      INDEX_NAME: search
    ports:
      - "4000:4000"
    networks:
      default:
        aliases:
          - search-api

  store-ui:
    image: ahmedsabra/cloudnova-store-ui:latest
    container_name: cloudnova-store-ui
    restart: unless-stopped
    depends_on:
      - products-service
      - users-service
      - cart-service
      - search-service
    ports:
      - "80:80"
YAML

docker compose -f /opt/cloudnova/docker-compose.yml up -d

cat > /opt/cloudnova/index-all-products.py <<'PY'
import json
import time
import urllib.request
import urllib.error

PRODUCTS_URL = "http://localhost:5000/products"
ES = "http://localhost:9200"
INDEX = "search"

def request(method, url, data=None):
    body = None
    headers = {"Content-Type": "application/json"}
    if data is not None:
        body = json.dumps(data).encode("utf-8")
    req = urllib.request.Request(url, data=body, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.status, r.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8")

def get_json(url):
    with urllib.request.urlopen(url, timeout=30) as r:
        return json.loads(r.read().decode("utf-8"))

for i in range(60):
    try:
        get_json(ES)
        data = get_json(PRODUCTS_URL)
        break
    except Exception as e:
        print("Waiting for services:", e)
        time.sleep(5)
else:
    raise SystemExit("Elasticsearch or Products API not ready")

if isinstance(data, dict):
    products = data.get("products", [])
elif isinstance(data, list):
    products = data
else:
    products = []

print("Products found:", len(products))

request("DELETE", f"{ES}/{INDEX}")

mapping = {
    "mappings": {
        "properties": {
            "id": {"type": "keyword"},
            "title": {"type": "text"},
            "name": {"type": "text"},
            "description": {"type": "text"},
            "category": {"type": "text"},
            "brand": {"type": "text"},
            "price": {"type": "float"},
            "thumbnail": {"type": "text"},
            "image": {"type": "text"}
        }
    }
}

request("PUT", f"{ES}/{INDEX}", mapping)

for p in products:
    product_id = str(p.get("id"))
    doc = {
        "id": product_id,
        "title": p.get("title", ""),
        "name": p.get("title", ""),
        "description": p.get("description", ""),
        "category": p.get("category", ""),
        "brand": p.get("brand", ""),
        "price": p.get("price", 0),
        "thumbnail": p.get("thumbnail", ""),
        "image": p.get("thumbnail", "")
    }
    request("POST", f"{ES}/{INDEX}/_doc/{product_id}", doc)

request("POST", f"{ES}/{INDEX}/_refresh")
print("Indexing completed successfully")
PY

cat > /opt/cloudnova/reindex-products.sh <<'SH'
#!/bin/bash
set -e
python3 /opt/cloudnova/index-all-products.py
curl -s "http://localhost:9200/search/_count"
SH

chmod +x /opt/cloudnova/reindex-products.sh

sleep 90
/opt/cloudnova/reindex-products.sh >> /var/log/cloudnova-indexer.log 2>&1 || true

(crontab -l 2>/dev/null | grep -v cloudnova-indexer || true; echo "*/5 * * * * /opt/cloudnova/reindex-products.sh >> /var/log/cloudnova-indexer.log 2>&1") | crontab -
