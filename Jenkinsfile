pipeline {
    agent any  // Rulează pe orice agent disponibil

    environment {
        DOCKER_IMAGE = "docker.io/tricarobert/demoapp:latest"  
        K8S_DEPLOYMENT = "aplicatie"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Robert-Mihai-Trica/Demoapplts.git'
            }
        }

        stage('Build & Test') {
            steps {
                script {
                    sh 'docker build -t aplicatie:latest .'
                    sh 'docker run --rm aplicatie:latest mvn test'  // Corectat testarea cu Maven
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    sh 'docker tag aplicatie:latest ${DOCKER_IMAGE}'
                    sh 'docker login -u "tricarobert" -p "$DOCKERHUB_PASSWORD"'
                    sh 'docker push ${DOCKER_IMAGE}'
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    sh 'kubectl config use-context minikube'
                    sh 'kubectl delete deployment "${K8S_DEPLOYMENT}" --ignore-not-found=true'
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
