pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "tricarobert/myapp:${env.BUILD_ID}"
        DOCKER_REGISTRY = "docker.io"
        KUBERNETES_NAMESPACE = "default"
        KUBERNETES_DEPLOYMENT_NAME = "demoapp"
        KUBECONFIG = "/home/robert/.minikube/profiles/minikube/"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Robert-Mihai-Trica/Demoapplts.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                    sh 'docker images'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'Docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin ${DOCKER_REGISTRY}"
                    }
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh 'kubectl config get-contexts'
                    sh 'kubectl config use-context minikube'
                    sh """
                    kubectl set image deployment/${KUBERNETES_DEPLOYMENT_NAME} ${KUBERNETES_DEPLOYMENT_NAME}=${DOCKER_REGISTRY}/${DOCKER_IMAGE}
                    kubectl rollout status deployment/${KUBERNETES_DEPLOYMENT_NAME}
                    """
                }
            }
        }

        stage('Results') {
            steps {
                junit '**/target/surefire-reports/*.xml'
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f'
        }
    }
}
