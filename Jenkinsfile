pipeline {
agent any

environment {
    DOCKERHUB_USER = 'ahmedsabra'
    K8S_NAMESPACE = 'cloudnova'

    STORE_UI_IMAGE = 'ahmedsabra/cloudnova-store-ui'
    PRODUCTS_IMAGE = 'ahmedsabra/cloudnova-products-api'
    USERS_IMAGE = 'ahmedsabra/cloudnova-users-api'
    CART_IMAGE = 'ahmedsabra/cloudnova-cart-api'
    SEARCH_IMAGE = 'ahmedsabra/cloudnova-search-api'

    IMAGE_TAG = "build-${BUILD_NUMBER}"

    HOST_WORKSPACE = '/home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline'

    KUBECTL = 'docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v /home/u1/jenkins_home/.kube:/root/.kube -v /home/u1/jenkins_home/.minikube:/root/.minikube -v /home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline:/workspace -w /workspace bitnami/kubectl:latest'
}

stages {
    stage('Checkout') {
        steps {
            echo 'Checking out source code...'
            checkout scm
        }
    }

    stage('Workspace Info') {
        steps {
            sh '''
                echo "Current Jenkins workspace:"
                pwd

                echo "Host workspace:"
                echo "$HOST_WORKSPACE"

                echo "Project files:"
                ls -la
            '''
        }
    }

    stage('Trivy File System Scan') {
        steps {
            echo 'Running Trivy filesystem scan...'
            sh '''
                docker run --rm \
                  -v $HOST_WORKSPACE:/workspace \
                  aquasec/trivy:latest fs \
                  --severity HIGH,CRITICAL \
                  --exit-code 0 \
                  /workspace
            '''
        }
    }

    stage('Build Store UI Static Files') {
    steps {
        timeout(time: 15, unit: 'MINUTES') {
            echo 'Building React Store UI static files...'
            sh '''
            docker run --rm \
              -e CI=false \
              -e NODE_OPTIONS="--max_old_space_size=2048" \
              -v "$WORKSPACE:/workspace" \
              -w /workspace/store-ui \
              node:18-alpine \
              sh -c "rm -rf node_modules build && npm ci --no-audit --no-fund --progress=false && npm run build"
            '''
        }
    }
}

        stage('Build Cart Service JAR') {
            steps {
                echo 'Building Cart Service JAR...'
                sh '''                    docker run --rm \
                      -v $HOST_WORKSPACE:/workspace \
                      -w /workspace/cart-cna-microservice \
                      gradle:8.7-jdk17-alpine \
                      sh -c 'gradle clean build -x test && mkdir -p build/libs && JAR_FILE=$(ls build/libs/*.jar | grep -v plain | head -n 1) && cp "$JAR_FILE" build/libs/cart-1.0.0.jar && ls -lah build/libs'
                '''
            }
        }

    stage('Build Docker Images') {
        steps {
            echo 'Building Docker images...'
            sh '''
                docker build -t $STORE_UI_IMAGE:$IMAGE_TAG -t $STORE_UI_IMAGE:latest ./store-ui
                docker build -t $PRODUCTS_IMAGE:$IMAGE_TAG -t $PRODUCTS_IMAGE:latest ./products-cna-microservice
                docker build -t $USERS_IMAGE:$IMAGE_TAG -t $USERS_IMAGE:latest ./users-cna-microservice
                docker build -t $CART_IMAGE:$IMAGE_TAG -t $CART_IMAGE:latest ./cart-cna-microservice
                docker build -t $SEARCH_IMAGE:$IMAGE_TAG -t $SEARCH_IMAGE:latest ./search-cna-microservice
            '''
        }
    }

    stage('Trivy Image Scan') {
        steps {
            echo 'Scanning Docker images with Trivy...'
            sh '''
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 0 $STORE_UI_IMAGE:$IMAGE_TAG
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 0 $PRODUCTS_IMAGE:$IMAGE_TAG
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 0 $USERS_IMAGE:$IMAGE_TAG
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 0 $CART_IMAGE:$IMAGE_TAG
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 0 $SEARCH_IMAGE:$IMAGE_TAG
            '''
        }
    }

    stage('Push Docker Images') {
        steps {
            echo 'Pushing Docker images to DockerHub...'
            withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                    docker push $STORE_UI_IMAGE:$IMAGE_TAG
                    docker push $STORE_UI_IMAGE:latest

                    docker push $PRODUCTS_IMAGE:$IMAGE_TAG
                    docker push $PRODUCTS_IMAGE:latest

                    docker push $USERS_IMAGE:$IMAGE_TAG
                    docker push $USERS_IMAGE:latest

                    docker push $CART_IMAGE:$IMAGE_TAG
                    docker push $CART_IMAGE:latest

                    docker push $SEARCH_IMAGE:$IMAGE_TAG
                    docker push $SEARCH_IMAGE:latest
                '''
            }
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
                $KUBECTL rollout status deployment/products-service -n $K8S_NAMESPACE --timeout=180s
                $KUBECTL rollout status deployment/users-service -n $K8S_NAMESPACE --timeout=180s
                $KUBECTL rollout status deployment/cart-service -n $K8S_NAMESPACE --timeout=180s
                $KUBECTL rollout status deployment/search-service -n $K8S_NAMESPACE --timeout=180s
                $KUBECTL rollout status deployment/store-ui -n $K8S_NAMESPACE --timeout=180s

                echo "Final pods status:"
                $KUBECTL get pods -n $K8S_NAMESPACE

                echo "Final services status:"
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
        echo 'CloudNova Commerce CI/CD Pipeline failed. Please check the console output.'
    }
}

}
