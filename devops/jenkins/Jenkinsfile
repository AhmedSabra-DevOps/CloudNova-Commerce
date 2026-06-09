pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'ahmedsabra'
        K8S_NAMESPACE = 'cloudnova'
        KUBECTL = 'docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v $HOME/.kube:/root/.kube -v $HOME/.minikube:$HOME/.minikube -v $PWD:/workspace -w /workspace bitnami/kubectl:latest'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Build Docker Images') {
            steps {
                echo 'Building Docker images...'
                sh '''
                    docker build -t $DOCKERHUB_USER/cloudnova-store-ui:latest ./store-ui
                    docker build -t $DOCKERHUB_USER/cloudnova-products-api:latest ./products-cna-microservice
                    docker build -t $DOCKERHUB_USER/cloudnova-users-api:latest ./users-cna-microservice
                    docker build -t $DOCKERHUB_USER/cloudnova-cart-api:latest ./cart-cna-microservice
                    docker build -t $DOCKERHUB_USER/cloudnova-search-api:latest ./search-cna-microservice
                '''
            }
        }

        stage('Push Docker Images') {
            steps {
                echo 'Pushing Docker images to DockerHub...'
                sh '''
                    docker push $DOCKERHUB_USER/cloudnova-store-ui:latest
                    docker push $DOCKERHUB_USER/cloudnova-products-api:latest
                    docker push $DOCKERHUB_USER/cloudnova-users-api:latest
                    docker push $DOCKERHUB_USER/cloudnova-cart-api:latest
                    docker push $DOCKERHUB_USER/cloudnova-search-api:latest
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying CloudNova Commerce to Kubernetes...'
                sh '''
                    $KUBECTL apply -f kubernetes/namespace.yaml
                    $KUBECTL apply -f kubernetes/redis.yaml
                    $KUBECTL apply -f kubernetes/mongo.yaml
                    $KUBECTL apply -f kubernetes/postgres.yaml
                    $KUBECTL apply -f kubernetes/elasticsearch.yaml

                    $KUBECTL apply -f kubernetes/products-service.yaml
                    $KUBECTL apply -f kubernetes/users-service.yaml
                    $KUBECTL apply -f kubernetes/cart-service.yaml
                    $KUBECTL apply -f kubernetes/search-service.yaml

                    $KUBECTL apply -f kubernetes/api-alias-services.yaml
                    $KUBECTL apply -f kubernetes/store-ui.yaml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying Kubernetes deployment...'
                sh '''
                    $KUBECTL rollout status deployment/products-service -n $K8S_NAMESPACE
                    $KUBECTL rollout status deployment/users-service -n $K8S_NAMESPACE
                    $KUBECTL rollout status deployment/cart-service -n $K8S_NAMESPACE
                    $KUBECTL rollout status deployment/search-service -n $K8S_NAMESPACE
                    $KUBECTL rollout status deployment/store-ui -n $K8S_NAMESPACE

                    $KUBECTL get pods -n $K8S_NAMESPACE
                    $KUBECTL get svc -n $K8S_NAMESPACE
                '''
            }
        }
    }

    post {
        success {
            echo 'CloudNova Commerce CI/CD Pipeline completed successfully.'
        }
        failure {
            echo 'CloudNova Commerce CI/CD Pipeline failed.'
        }
    }
}
