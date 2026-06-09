#!/bin/bash

set -e

echo "Deploying CloudNova Commerce to Kubernetes..."

kubectl apply -f namespace.yaml
kubectl apply -f redis.yaml
kubectl apply -f mongo.yaml
kubectl apply -f postgres.yaml
kubectl apply -f elasticsearch.yaml

kubectl apply -f products-service.yaml
kubectl apply -f users-service.yaml
kubectl apply -f cart-service.yaml
kubectl apply -f search-service.yaml

kubectl apply -f api-alias-services.yaml
kubectl apply -f store-ui.yaml

echo "Waiting for deployments..."
kubectl rollout status deployment/products-service -n cloudnova
kubectl rollout status deployment/users-service -n cloudnova
kubectl rollout status deployment/cart-service -n cloudnova
kubectl rollout status deployment/search-service -n cloudnova
kubectl rollout status deployment/store-ui -n cloudnova

echo "CloudNova Commerce deployed successfully."
kubectl get pods -n cloudnova
kubectl get svc -n cloudnova
