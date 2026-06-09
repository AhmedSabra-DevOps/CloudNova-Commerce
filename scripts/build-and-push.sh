#!/bin/bash

set -e

DOCKERHUB_USER="ahmedsabra"

echo "Building and pushing CloudNova Commerce images..."

echo "1. Building store-ui..."
docker build -t $DOCKERHUB_USER/cloudnova-store-ui:latest ./store-ui
docker push $DOCKERHUB_USER/cloudnova-store-ui:latest

echo "2. Building products-api..."
docker build -t $DOCKERHUB_USER/cloudnova-products-api:latest ./products-cna-microservice
docker push $DOCKERHUB_USER/cloudnova-products-api:latest

echo "3. Building users-api..."
docker build -t $DOCKERHUB_USER/cloudnova-users-api:latest ./users-cna-microservice
docker push $DOCKERHUB_USER/cloudnova-users-api:latest

echo "4. Building cart-api..."
docker build -t $DOCKERHUB_USER/cloudnova-cart-api:latest ./cart-cna-microservice
docker push $DOCKERHUB_USER/cloudnova-cart-api:latest

echo "5. Building search-api..."
docker build -t $DOCKERHUB_USER/cloudnova-search-api:latest ./search-cna-microservice
docker push $DOCKERHUB_USER/cloudnova-search-api:latest

echo "All images built and pushed successfully."
