pipeline {
    agent any

    environment {
        HOST_WORKSPACE = '/home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline'
        DOCKERHUB_USER = 'AhmedSabra'

        STORE_UI_IMAGE = "${DOCKERHUB_USER}/cloudnova-store-ui"
        PRODUCTS_IMAGE = "${DOCKERHUB_USER}/cloudnova-products-service"
        SEARCH_IMAGE = "${DOCKERHUB_USER}/cloudnova-search-service"
        USERS_IMAGE = "${DOCKERHUB_USER}/cloudnova-users-service"
        CART_IMAGE = "${DOCKERHUB_USER}/cloudnova-cart-service"

        IMAGE_TAG = "${BUILD_NUMBER}"
        K8S_NAMESPACE = 'cloudnova'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
                sh '''
                echo "Current workspace:"
                pwd
                ls -lah
                '''
            }
        }

        stage('Trivy File System Scan') {
            steps {
                echo 'Running Trivy filesystem scan...'
                sh '''
                docker run --rm \
                  -v "${HOST_WORKSPACE}:/workspace" \
                  aquasec/trivy:latest fs \
                  --scanners vuln \
                  --severity HIGH,CRITICAL \
                  --no-progress \
                  /workspace || true
                '''
            }
        }

        stage('Build Store UI Static Files') {
    steps {
        timeout(time: 10, unit: 'MINUTES') {
            echo 'Building Store UI using existing node_modules...'
            sh '''
            docker run --rm \
              -e CI=false \
              -e NODE_OPTIONS="--max_old_space_size=2048" \
              -v "${HOST_WORKSPACE}:/workspace" \
              -w /workspace/store-ui \
              node:18-alpine \
              sh -c "npm run build && ls -lah build"
            '''
        }
    }
}

        stage('Build Cart Service JAR') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    echo 'Building Cart Service JAR...'
                    sh '''
                    docker run --rm \
                      -v "${HOST_WORKSPACE}:/workspace" \
                      -w /workspace/cart-cna-microservice \
                      gradle:8.7-jdk17-alpine \
                      sh -c "gradle clean build -x test && ls -lah build/libs"
                    '''
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                echo 'Building Docker images...'
                sh '''
                docker build -t ${STORE_UI_IMAGE}:${IMAGE_TAG} -t ${STORE_UI_IMAGE}:latest store-ui
                docker build -t ${PRODUCTS_IMAGE}:${IMAGE_TAG} -t ${PRODUCTS_IMAGE}:latest products-cna-microservice
                docker build -t ${SEARCH_IMAGE}:${IMAGE_TAG} -t ${SEARCH_IMAGE}:latest search-cna-microservice
                docker build -t ${USERS_IMAGE}:${IMAGE_TAG} -t ${USERS_IMAGE}:latest users-cna-microservice
                docker build -t ${CART_IMAGE}:${IMAGE_TAG} -t ${CART_IMAGE}:latest cart-cna-microservice

                docker images | grep cloudnova || true
                '''
            }
        }

        stage('Trivy Image Scan') {
            steps {
                echo 'Running Trivy image scans...'
                sh '''
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --scanners vuln --severity HIGH,CRITICAL --no-progress ${STORE_UI_IMAGE}:${IMAGE_TAG} || true
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --scanners vuln --severity HIGH,CRITICAL --no-progress ${PRODUCTS_IMAGE}:${IMAGE_TAG} || true
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --scanners vuln --severity HIGH,CRITICAL --no-progress ${SEARCH_IMAGE}:${IMAGE_TAG} || true
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --scanners vuln --severity HIGH,CRITICAL --no-progress ${USERS_IMAGE}:${IMAGE_TAG} || true
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --scanners vuln --severity HIGH,CRITICAL --no-progress ${CART_IMAGE}:${IMAGE_TAG} || true
                '''
            }
        }

        stage('Push Docker Images') {
            steps {
                echo 'Pushing Docker images to Docker Hub...'
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                    docker push ${STORE_UI_IMAGE}:${IMAGE_TAG}
                    docker push ${STORE_UI_IMAGE}:latest

                    docker push ${PRODUCTS_IMAGE}:${IMAGE_TAG}
                    docker push ${PRODUCTS_IMAGE}:latest

                    docker push ${SEARCH_IMAGE}:${IMAGE_TAG}
                    docker push ${SEARCH_IMAGE}:latest

                    docker push ${USERS_IMAGE}:${IMAGE_TAG}
                    docker push ${USERS_IMAGE}:latest

                    docker push ${CART_IMAGE}:${IMAGE_TAG}
                    docker push ${CART_IMAGE}:latest
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                sh '''
                kubectl apply -f kubernetes/ -n ${K8S_NAMESPACE}
                '''
            }
        }

        stage('Restart Deployments') {
            steps {
                echo 'Restarting deployments...'
                sh '''
                kubectl rollout restart deployment/store-ui -n ${K8S_NAMESPACE} || true
                kubectl rollout restart deployment/products-service -n ${K8S_NAMESPACE} || true
                kubectl rollout restart deployment/search-service -n ${K8S_NAMESPACE} || true
                kubectl rollout restart deployment/users-service -n ${K8S_NAMESPACE} || true
                kubectl rollout restart deployment/cart-service -n ${K8S_NAMESPACE} || true
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                sh '''
                kubectl get pods -n ${K8S_NAMESPACE}
                kubectl get svc -n ${K8S_NAMESPACE}

                kubectl rollout status deployment/store-ui -n ${K8S_NAMESPACE} --timeout=120s || true
                kubectl rollout status deployment/products-service -n ${K8S_NAMESPACE} --timeout=120s || true
                kubectl rollout status deployment/search-service -n ${K8S_NAMESPACE} --timeout=120s || true
                kubectl rollout status deployment/users-service -n ${K8S_NAMESPACE} --timeout=120s || true
                kubectl rollout status deployment/cart-service -n ${K8S_NAMESPACE} --timeout=120s || true
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

        always {
            echo 'Pipeline finished.'
        }
    }
}
