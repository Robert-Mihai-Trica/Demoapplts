pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "tricarobert/myapp:${env.BUILD_ID}"
        DOCKER_REGISTRY = "docker.io"
        KUBERNETES_NAMESPACE = "default"
        KUBERNETES_DEPLOYMENT_NAME = "demoapp"
        K8S_CONTEXT = "minikube"
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

        stage('Prepare Kubeconfig from Secret') {
            steps {
                script {
                    // Injectează secretul kubeconfig în variabila de mediu
                    withCredentials([string(credentialsId: 'kubeconfig-secret', variable: 'KUBECONFIG_CONTENT')]) {
                        // Creează fișierul kubeconfig temporar în locația corespunzătoare
                        writeFile file: '/tmp/kubeconfig', text: "${KUBECONFIG_CONTENT}"
                        
                        // Setează variabila de mediu KUBECONFIG pentru a folosi acest fișier temporar
                        sh 'export KUBECONFIG=/tmp/kubeconfig'
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh "kubectl config use-context ${K8S_CONTEXT}"
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

