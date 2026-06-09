#!/bin/bash

PRODUCTS_URL="http://localhost:5001/products"
ELASTIC_URL="http://localhost:9201"
INDEX_NAME="search"

echo "Deleting old index..."
curl -s -X DELETE "$ELASTIC_URL/$INDEX_NAME" > /dev/null

echo "Creating index..."
curl -s -X PUT "$ELASTIC_URL/$INDEX_NAME" \
  -H "Content-Type: application/json" \
  -d '{
    "mappings": {
      "properties": {
        "id": { "type": "keyword" },
        "title": { "type": "text" },
        "description": { "type": "text" },
        "category": { "type": "text" },
        "brand": { "type": "text" },
        "price": { "type": "float" },
        "thumbnail": { "type": "keyword" }
      }
    }
  }' > /dev/null

echo "Fetching products..."
products=$(curl -s "$PRODUCTS_URL")

echo "$products" | jq -c '.[]' | while read -r product; do
  id=$(echo "$product" | jq -r '.id // ._id')
  title=$(echo "$product" | jq -r '.title')
  description=$(echo "$product" | jq -r '.description')
  category=$(echo "$product" | jq -r '.category')
  brand=$(echo "$product" | jq -r '.brand // .attributes.brand // "Generic"')
  price=$(echo "$product" | jq -r '.price')
  thumbnail=$(echo "$product" | jq -r '.thumbnail')

  echo "Indexing: $title"

  curl -s -X POST "$ELASTIC_URL/$INDEX_NAME/_doc/$id" \
    -H "Content-Type: application/json" \
    -d "{
      \"id\": \"$id\",
      \"title\": \"$title\",
      \"description\": \"$description\",
      \"category\": \"$category\",
      \"brand\": \"$brand\",
      \"price\": $price,
      \"thumbnail\": \"$thumbnail\"
    }" > /dev/null
done

curl -s -X POST "$ELASTIC_URL/$INDEX_NAME/_refresh" > /dev/null

echo "Done. Products indexed successfully."
