pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/Robert-Mihai-Trica/DemoApp.git'
        BRANCH = 'main'
        APP_NAME = 'demo-app'
        IMAGE_NAME = 'demo-app:latest'
        DEPLOYMENT_YAML = 'k8s/deployment.yaml'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: "${BRANCH}", url: "${REPO_URL}"
            }
        }

        stage('Build & Test') {
            steps {
                sh 'mvn clean package'
                sh 'mvn test'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME} .'
            }
        }

        stage('Load Image into Minikube') {
            steps {
                sh 'minikube image load ${IMAGE_NAME}'
            }
        }

        stage('Deploy to Minikube') {
            steps {
                sh 'kubectl apply -f ${DEPLOYMENT_YAML}'
            }
        }

        stage('Verify Deployment') {
            steps {
                sh 'kubectl get pods'
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
