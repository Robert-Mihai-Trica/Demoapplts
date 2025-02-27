pipeline {
    agent any

    }

    environment {
        DOCKER_IMAGE = "docker.io/tricarobert/demoapp:latest"
        K8S_DEPLOYMENT = "aplicatie"
        KUBECONFIG = "/root/.kube/config"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Robert-Mihai-Trica/Demoapplts.git'
            }
        }

        stage('Build & Test') {
            steps {
                script {
                    sh 'docker build --target build -t DEMOAPP-COPY .'
                    sh 'docker run --rm DEMOAPP-COPY mvn test'
                }
            }
        }


        stage('Build Final Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([string(credentialsId: 'docker-hub-pass', variable: 'DOCKERHUB_PASSWORD')]) {
                    sh 'echo "${DOCKERHUB_PASSWORD}" | docker login -u "tricarobert" --password-stdin'
                }
                script {
                    sh "docker tag ${DOCKER_IMAGE} ${DOCKER_IMAGE}"
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    sh 'kubectl config use-context minikube || minikube start'
                    sh "kubectl delete deployment ${K8S_DEPLOYMENT} --ignore-not-found=true"
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
