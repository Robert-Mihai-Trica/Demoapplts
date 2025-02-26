pipeline {
    agent { label 'docker' } // Rulează pe agentul cu Docker

    environment {
        DOCKER_IMAGE = "docker.io/tricarobert/aplicatie"  // Înlocuiește "username" cu contul tău Docker Hub
        K8S_DEPLOYMENT = "aplicatie"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Robert-Mihai-Trica/Demoapplts.git' // Înlocuiește cu repo-ul tău
            }
        }

        stage('Build & Test') {
            steps {
                script {
                    sh 'docker build -t aplicatie:latest .'
                    sh 'docker run --rm aplicatie:latest maven tests/' // Ajustează dacă folosești alt framework de testare
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub-cred', url: '']) {
                    sh "docker tag aplicatie:latest $DOCKER_IMAGE:latest"
                    sh "docker push $DOCKER_IMAGE:latest"
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    sh 'kubectl config use-context minikube'
                    sh 'kubectl delete deployment $K8S_DEPLOYMENT --ignore-not-found=true'
                    sh 'kubectl apply -f k8s/deployment.yaml'
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    sh 'kubectl get pods'
                    sh 'kubectl get services'
                }
            }
        }
    }
}
