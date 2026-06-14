pipeline {
    agent any

    environment {
        HOST_WORKSPACE = '/home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline'
        DOCKERHUB_USER = 'ahmedsabra'

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
              sh -c "npm install && npm run build && ls -lah build"
            '''
        }
    }
}

        stage('Build Cart Service JAR') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    echo 'Building Cart Service JAR...'
                    sh '''
                    docker run --rm --network host \
                      -v "${HOST_WORKSPACE}:/workspace" \
                      -v /home/u1/.gradle-cache-cloudnova:/home/gradle/.gradle \
                      -w /workspace/cart-cna-microservice \
                      gradle:8.7-jdk17-alpine \
                      sh -c "gradle clean build -x test --no-daemon && ls -lah build/libs"
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
                echo 'Skipping long Trivy image scan temporarily because Trivy DB download is timing out.'
                sh '''
                    echo "Docker images built successfully:"
                    docker images | grep cloudnova || true
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


        stage('Kubernetes Security Validation') {
            steps {
                echo 'Running Kubernetes manifest security validation...'
                sh '''                    echo "Checking for risky Kubernetes configurations..."

                    if grep -R "privileged: true" kubernetes/; then
                      echo "ERROR: privileged containers found"
                      exit 1
                    fi

                    if grep -R "hostNetwork: true" kubernetes/; then
                      echo "ERROR: hostNetwork usage found"
                      exit 1
                    fi

                    if grep -R "hostPID: true" kubernetes/; then
                      echo "ERROR: hostPID usage found"
                      exit 1
                    fi

                    if grep -R "hostIPC: true" kubernetes/; then
                      echo "ERROR: hostIPC usage found"
                      exit 1
                    fi

                    echo "Basic Kubernetes security validation passed."
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                sh '''
                docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v /home/u1/jenkins_home/.kube:/root/.kube -v /home/u1/jenkins_home/.minikube:/root/.minikube -v /home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline:/workspace -w /workspace bitnami/kubectl:latest apply -f kubernetes/ -n ${K8S_NAMESPACE}
                '''
            }
        }

        stage('Restart Deployments') {
            steps {
                echo 'Restarting deployments...'
                sh '''
                docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v /home/u1/jenkins_home/.kube:/root/.kube -v /home/u1/jenkins_home/.minikube:/root/.minikube -v /home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline:/workspace -w /workspace bitnami/kubectl:latest rollout restart deployment/store-ui -n ${K8S_NAMESPACE} || true
                docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v /home/u1/jenkins_home/.kube:/root/.kube -v /home/u1/jenkins_home/.minikube:/root/.minikube -v /home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline:/workspace -w /workspace bitnami/kubectl:latest rollout restart deployment/products-service -n ${K8S_NAMESPACE} || true
                docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v /home/u1/jenkins_home/.kube:/root/.kube -v /home/u1/jenkins_home/.minikube:/root/.minikube -v /home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline:/workspace -w /workspace bitnami/kubectl:latest rollout restart deployment/search-service -n ${K8S_NAMESPACE} || true
                docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v /home/u1/jenkins_home/.kube:/root/.kube -v /home/u1/jenkins_home/.minikube:/root/.minikube -v /home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline:/workspace -w /workspace bitnami/kubectl:latest rollout restart deployment/users-service -n ${K8S_NAMESPACE} || true
                docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v /home/u1/jenkins_home/.kube:/root/.kube -v /home/u1/jenkins_home/.minikube:/root/.minikube -v /home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline:/workspace -w /workspace bitnami/kubectl:latest rollout restart deployment/cart-service -n ${K8S_NAMESPACE} || true
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                sh '''
                docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v /home/u1/jenkins_home/.kube:/root/.kube -v /home/u1/jenkins_home/.minikube:/root/.minikube -v /home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline:/workspace -w /workspace bitnami/kubectl:latest get pods -n ${K8S_NAMESPACE}
                docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v /home/u1/jenkins_home/.kube:/root/.kube -v /home/u1/jenkins_home/.minikube:/root/.minikube -v /home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline:/workspace -w /workspace bitnami/kubectl:latest get svc -n ${K8S_NAMESPACE}

                docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v /home/u1/jenkins_home/.kube:/root/.kube -v /home/u1/jenkins_home/.minikube:/root/.minikube -v /home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline:/workspace -w /workspace bitnami/kubectl:latest rollout status deployment/store-ui -n ${K8S_NAMESPACE} --timeout=120s || true
                docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v /home/u1/jenkins_home/.kube:/root/.kube -v /home/u1/jenkins_home/.minikube:/root/.minikube -v /home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline:/workspace -w /workspace bitnami/kubectl:latest rollout status deployment/products-service -n ${K8S_NAMESPACE} --timeout=120s || true
                docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v /home/u1/jenkins_home/.kube:/root/.kube -v /home/u1/jenkins_home/.minikube:/root/.minikube -v /home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline:/workspace -w /workspace bitnami/kubectl:latest rollout status deployment/search-service -n ${K8S_NAMESPACE} --timeout=120s || true
                docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v /home/u1/jenkins_home/.kube:/root/.kube -v /home/u1/jenkins_home/.minikube:/root/.minikube -v /home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline:/workspace -w /workspace bitnami/kubectl:latest rollout status deployment/users-service -n ${K8S_NAMESPACE} --timeout=120s || true
                docker run --rm --network host --user root -e KUBECONFIG=/root/.kube/config -v /home/u1/jenkins_home/.kube:/root/.kube -v /home/u1/jenkins_home/.minikube:/root/.minikube -v /home/u1/jenkins_home/workspace/cloudnova-commerce-pipeline:/workspace -w /workspace bitnami/kubectl:latest rollout status deployment/cart-service -n ${K8S_NAMESPACE} --timeout=120s || true
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
