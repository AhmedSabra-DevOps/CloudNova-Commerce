# CloudNova Commerce

CloudNova Commerce is a cloud-native e-commerce microservices platform designed to demonstrate modern DevOps, cloud deployment, CI/CD automation, containerization, monitoring, and security validation practices.

The project shows how a real e-commerce application can be built, containerized, deployed, exposed, monitored, and automated using a production-style DevOps workflow.

---

## Project Information

| Field             | Details                                                 |
| ----------------- | ------------------------------------------------------- |
| Project Name      | CloudNova Commerce                                      |
| Project Type      | E-commerce Microservices Platform                       |
| Track             | Software Development                                    |
| Job Profile       | DevOps Specialist                                       |
| Program           | Nano Degree                                             |
| Team Name         | CloudNova Team                                          |
| Deployment Target | AWS Cloud / EC2 / Kubernetes-ready                      |
| Repository        | https://github.com/AhmedSabra-DevOps/CloudNova-Commerce |
| Submission        | June 2026                                               |

---

## Team Members

| Name                            | ID             | Main Role                             |
| ------------------------------- | -------------- | ------------------------------------- |
| Ebrahim Ashraf Ebrahim Metwally | 29603191201014 | Software Development / Implementation |
| Ahmed Abdo Metwally Sabra       | 29903101502499 | DevOps / Cloud Deployment / CI/CD     |

---

## Academic Supervision

| Role          | Name                                           |
| ------------- | ---------------------------------------------- |
| Supervisor    | Prof. Dr. Rania Elgohary                       |
| Track Head    | Dr. Mohamed Elnabawy                           |
| Academic Team | Eng. Abdulrahman Magdey, Eng. Abdullah Mahmoud |

---

## Project Overview

CloudNova Commerce is a microservices-based e-commerce system. Instead of building the application as one large monolithic system, the platform is divided into independent services.

Each service can be developed, containerized, deployed, monitored, and updated separately. This makes the system easier to maintain, scale, troubleshoot, and improve.

The project focuses on both application functionality and DevOps engineering. It demonstrates the complete lifecycle from source code to cloud deployment.

---

## Main Features

* Product catalog browsing through a modern web interface
* Shopping cart service
* User service
* Product search using Elasticsearch
* Dockerized microservices
* Docker Compose deployment
* Kubernetes-ready manifests
* Jenkins CI/CD pipeline
* Trivy security scanning
* Terraform-based AWS infrastructure
* AWS EC2 cloud deployment
* Application Load Balancer exposure
* Monitoring readiness with Prometheus and Grafana
* Automated product indexing into Elasticsearch

---

## High-Level Architecture

```text
User
  |
  v
AWS Application Load Balancer
  |
  v
EC2 Instance
  |
  v
Docker Compose
  |
  +--> Store UI
  +--> Products Service --> MongoDB
  +--> Users Service -----> PostgreSQL
  +--> Cart Service ------> Redis
  +--> Search Service ----> Elasticsearch
```

---

## Microservices

| Service          | Technology         |  Port | Description              |
| ---------------- | ------------------ | ----: | ------------------------ |
| Store UI         | React + Nginx      |    80 | Customer-facing frontend |
| Products Service | Node.js            |  5000 | Product catalog API      |
| Users Service    | Python / FastAPI   |  9090 | User-related service     |
| Cart Service     | Java / Spring Boot |  8080 | Shopping cart service    |
| Search Service   | Node.js            |  4000 | Search API               |
| MongoDB          | MongoDB            | 27017 | Product data storage     |
| PostgreSQL       | PostgreSQL         |  5432 | User database            |
| Redis            | Redis              |  6379 | Cart cache               |
| Elasticsearch    | Elasticsearch 7.17 |  9200 | Search engine            |

---

## Technology Stack

### Application Stack

* React
* Node.js
* Python / FastAPI
* Java / Spring Boot
* Nginx

### Database and Cache

* MongoDB
* PostgreSQL
* Redis
* Elasticsearch

### DevOps and Cloud Stack

* GitHub
* Docker
* Docker Compose
* Kubernetes
* Minikube
* Jenkins
* Terraform
* AWS EC2
* AWS VPC
* AWS Security Groups
* AWS Application Load Balancer
* Docker Hub

### Security and Quality

* Trivy filesystem scanning
* Trivy image scanning
* Kubernetes manifest validation
* Git ignore rules for Terraform state and secrets

### Monitoring

* Prometheus
* Grafana
* Kubernetes metrics validation

---

## Repository Structure

```text
CloudNova-Commerce/
├── cart-service/
├── products-service/
├── users-service/
├── search-service/
├── store-ui/
├── kubernetes/
├── terraform-ec2-compose/
│   ├── main.tf
│   ├── variables.tf
│   ├── user_data.sh
│   ├── alb.tf
│   └── .terraform.lock.hcl
├── Jenkinsfile
├── docker-compose.yml
├── .gitignore
└── README.md
```

---

## Local Deployment with Docker Compose

Run the project locally:

```bash
docker compose up -d
```

Check running containers:

```bash
docker compose ps
```

Open the frontend:

```text
http://localhost
```

---

## Kubernetes Validation

The project was validated using Kubernetes and Minikube.

Useful commands:

```bash
kubectl get namespaces
kubectl get pods -n cloudnova
kubectl get svc -n cloudnova
kubectl get deployments -n cloudnova
```

Expose the frontend locally:

```bash
kubectl port-forward --address 0.0.0.0 -n cloudnova svc/store-ui 9091:80
```

Open:

```text
http://localhost:9091
```

---

## Jenkins CI/CD Pipeline

The Jenkins pipeline automates the build, scan, push, deploy, and verification process.

Pipeline stages:

1. Checkout source code from GitHub
2. Run Trivy filesystem scan
3. Build Store UI static files
4. Build Cart Service JAR
5. Build Docker images
6. Run Trivy image scan
7. Push images to Docker Hub
8. Validate Kubernetes security configuration
9. Deploy to Kubernetes
10. Verify deployment status

This makes the release process repeatable, traceable, and easier to troubleshoot.

---

## Docker Images

Docker images are pushed to Docker Hub under:

```text
ahmedsabra
```

Main images:

```text
ahmedsabra/cloudnova-store-ui:latest
ahmedsabra/cloudnova-products-service:latest
ahmedsabra/cloudnova-users-service:latest
ahmedsabra/cloudnova-cart-service:latest
ahmedsabra/cloudnova-search-service:latest
```

---

## AWS Infrastructure

Terraform provisions the AWS cloud environment.

Main resources:

* Custom VPC
* Public subnets
* Internet Gateway
* Public Route Table
* Security Groups
* EC2 instance
* SSH key pair
* Application Load Balancer
* Target Group
* ALB Listener
* Docker and Docker Compose installation through user data

---

## Terraform Deployment

Move to the Terraform directory:

```bash
cd terraform-ec2-compose
```

Initialize Terraform:

```bash
terraform init
```

Review the plan:

```bash
terraform plan
```

Apply infrastructure:

```bash
terraform apply
```

Show outputs:

```bash
terraform output
```

Destroy resources after finishing the demo:

```bash
terraform destroy
```

---

## Terraform Variables

Create a local file named:

```text
terraform.tfvars
```

Example:

```hcl
aws_region      = "us-east-1"
instance_type   = "t2.small"
my_ip_cidr      = "YOUR_PUBLIC_IP/32"
public_key_path = "~/.ssh/cloudnova-demo-key.pub"
```

Important: `terraform.tfvars` is ignored by Git because it may contain local or sensitive values.

---

## EC2 User Data Automation

The EC2 instance runs `user_data.sh` automatically during startup.

The script does the following:

* Installs Docker
* Installs Docker Compose
* Starts Docker service
* Creates 2GB swap for stability
* Creates `/opt/cloudnova`
* Generates Docker Compose configuration
* Runs all CloudNova services
* Adds service aliases:

  * `products-api`
  * `users-api`
  * `cart-api`
  * `search-api`
* Creates Elasticsearch product indexing script
* Indexes all products into Elasticsearch
* Adds a cron job to re-index products every 5 minutes

---

## Application Load Balancer

The project supports AWS Application Load Balancer exposure.

Final cloud flow:

```text
User
  |
  v
AWS Application Load Balancer
  |
  v
EC2 Instance
  |
  v
Docker Compose Microservices
```

This provides a more production-style access layer than using the EC2 public IP directly.

---

## Search Indexing

Elasticsearch is used to support product search.

Check indexed products:

```bash
curl "http://localhost:9200/search/_count"
```

Expected result:

```json
{
  "count": 70
}
```

Example search request:

```bash
curl "http://localhost:4000/search?q=beauty"
```

---

## EC2 Validation Commands

SSH into the EC2 instance:

```bash
ssh -o IdentitiesOnly=yes -i ~/.ssh/cloudnova-demo-key ubuntu@EC2_PUBLIC_IP
```

Check services:

```bash
cd /opt/cloudnova
sudo docker compose ps
```

Check memory and swap:

```bash
free -h
```

Check frontend:

```bash
curl -I http://localhost
```

Check Elasticsearch:

```bash
curl "http://localhost:9200/search/_count"
```

Check search service:

```bash
curl "http://localhost:4000/search?q=beauty"
```

---

## Security Practices

Security and reliability practices used in this project:

* Terraform state files are ignored from Git
* Terraform variable files are ignored from Git
* Docker images are scanned using Trivy
* Kubernetes manifests are checked for risky configurations
* Security Groups allow only required access
* Sensitive local files are not committed
* Services are separated through container networking
* Search indexing is automated to avoid manual recovery

---

## Monitoring and Observability

The project includes monitoring readiness using:

* Prometheus for metrics collection
* Grafana for dashboards
* Kubernetes runtime checks
* Container health checks
* Resource usage validation

Useful commands:

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
kubectl get pods -n cloudnova
kubectl top pods -n cloudnova
```

---

## Troubleshooting Highlights

### Store UI Nginx Upstream Issue

Problem:

```text
host not found in upstream "products-api"
```

Solution:

Docker Compose aliases were added:

```text
products-api
users-api
cart-api
search-api
```

---

### Elasticsearch Memory Issue

Problem:

Elasticsearch and Java services may fail on small-memory instances.

Solution:

* EC2 instance upgraded from `t2.micro` to `t2.small`
* 2GB swap was added
* Elasticsearch heap was reduced using `ES_JAVA_OPTS`

---

### Search Index Not Found

Problem:

```text
no such index [search]
```

Solution:

A Python indexing script was created to fetch all products from the Products Service and insert them into Elasticsearch automatically.

---

## Final Validation

The final deployment was validated with:

* All Docker Compose services running
* Store UI returning HTTP 200
* Elasticsearch index containing 70 products
* Search API returning product results
* Terraform infrastructure committed to GitHub
* EC2 deployment automated with user data
* Application Load Balancer added for production-style exposure
* Jenkins CI/CD pipeline prepared
* Monitoring stack prepared

---

## Final Cloud Access

Application URL through AWS Application Load Balancer:

```text
http://cloudnova-commerce-alb-1734040738.us-east-1.elb.amazonaws.com/
```

---

## Conclusion

CloudNova Commerce demonstrates a complete DevOps-oriented cloud-native delivery workflow for an e-commerce microservices platform. The project connects application development, Docker containerization, infrastructure automation, CI/CD, security validation, AWS cloud deployment, search indexing, monitoring readiness, and production-style access through an Application Load Balancer.

