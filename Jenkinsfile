pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "tricarobert/myapp:${env.BUILD_ID}"
        DOCKER_REGISTRY = "docker.io"
        KUBERNETES_NAMESPACE = "default"
        KUBERNETES_DEPLOYMENT_NAME = "demoapp"
        KUBECONFIG = '/tmp/kubeconfig'
        K8S_CONTEXT = "minikube"
    }
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Robert-Mihai-Trica/Demoapplts.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE} .'
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin ${DOCKER_REGISTRY}"
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Prepare kubeconfig') {
            steps {
                withCredentials([string(credentialsId: 'KUBECONFIG_SECRET', variable: 'KUBECONFIG_CONTENT')]) {
                    script {
                        writeFile(file: '/tmp/kubeconfig', text: KUBECONFIG_CONTENT)
                        sh 'export KUBECONFIG=/tmp/kubeconfig'
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh 'kubectl config use-context ${K8S_CONTEXT}'
                    sh "kubectl set image deployment/${KUBERNETES_DEPLOYMENT_NAME} ${KUBERNETES_DEPLOYMENT_NAME}=${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
                    sh "kubectl rollout status deployment/${KUBERNETES_DEPLOYMENT_NAME}"
                }
            }
        }
    }
    post {
        always {
            sh 'docker system prune -f'
        }
    }
}
