pipeline {
    agent any  

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
                    sh 'docker build --target build -t aplicatie-build .'
                    sh 'docker run --rm aplicatie-build mvn test'  // Acum rulăm testele în imaginea de build
                }
            }
        }

        stage('Build Final Image') {
            steps {
                script {
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    sh 'docker tag ${DOCKER_IMAGE} ${DOCKER_IMAGE}'
                    sh 'docker login -u "tricarobert" -p "Crush1234'
                    sh 'docker push ${DOCKER_IMAGE}'
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
            withCredentials([string(credentialsId: 'docker-hub-pass', variable: 'DOCKERHUB_PASSWORD')]) {
                sh 'echo "$DOCKERHUB_PASSWORD" | docker login -u "tricarobert" --password-stdin'
            }
            sh 'docker tag aplicatie:latest tricarobert/demoapp:latest'
            sh 'docker push tricarobert/demoapp:latest'
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
