#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io docker-compose-v2 curl

systemctl enable docker
systemctl start docker

mkdir -p /opt/cloudnova
cd /opt/cloudnova

cat > docker-compose.yml <<'COMPOSE'
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
      ES_JAVA_OPTS: "-Xms256m -Xmx256m"
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

  cart-service:
    image: ahmedsabra/cloudnova-cart-service:latest
    container_name: cloudnova-cart-service
    restart: unless-stopped
    depends_on:
      - db-cart
    environment:
      REDIS_HOST: db-cart
      REDIS_PORT: 6379
    ports:
      - "8080:8080"

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
COMPOSE

docker compose up -d
