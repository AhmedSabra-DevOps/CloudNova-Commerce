# CloudNova Commerce

**Built for Scale. Engineered for the Cloud.**

CloudNova Commerce is a cloud-native e-commerce microservices platform designed to demonstrate modern DevOps, containerization, CI/CD automation, and Kubernetes deployment practices.

The project consists of multiple independent services including frontend, products, users, cart, search, and supporting databases. It is containerized using Docker, deployed locally on Kubernetes using Minikube, and automated through a Jenkins CI/CD pipeline.

---

## Project Overview

CloudNova Commerce is built as a microservices-based e-commerce application. Each service is independently containerized and can be deployed, scaled, and maintained separately.

The main objective of this project is to apply real-world DevOps practices including:

- Docker containerization
- Kubernetes deployments and services
- Jenkins CI/CD pipeline
- DockerHub image registry
- Automated build, push, deploy, and verification
- Cloud-ready deployment structure for AWS EKS

---

## Architecture

The system contains the following components:

| Component | Technology | Description |
|---|---|---|
| Store UI | React + Nginx | Frontend user interface |
| Products API | Node.js + Express | Handles products data |
| Users API | Python + FastAPI | Handles users functionality |
| Cart API | Java Spring Boot | Handles shopping cart operations |
| Search API | Node.js + Express | Handles product search |
| MongoDB | Database | Products database |
| PostgreSQL | Database | Users database |
| Redis | Cache | Cart cache |
| Elasticsearch | Search Engine | Search indexing and search queries |

---

## DevOps Tools Used

| Tool | Usage |
|---|---|
| Docker | Containerizing all microservices |
| Docker Compose | Local multi-container environment |
| Kubernetes | Orchestrating application services |
| Minikube | Local Kubernetes cluster |
| Jenkins | CI/CD automation |
| DockerHub | Container image registry |
| kubectl | Kubernetes deployment management |
| Nginx | Frontend serving and API reverse proxy |

---

## DockerHub Images

The project images are pushed to DockerHub under the following repositories:

```text
ahmedsabra/cloudnova-store-ui:latest
ahmedsabra/cloudnova-products-api:latest
ahmedsabra/cloudnova-users-api:latest
ahmedsabra/cloudnova-cart-api:latest
ahmedsabra/cloudnova-search-api:latest
# CloudNova-Commerce
