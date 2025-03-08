pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "tricarobert/myapp:${env.BUILD_ID}"
        KUBERNETES_NAMESPACE = "default"
        KUBERNETES_DEPLOYMENT_NAME = "demoapp"
        KUBECONFIG = "/var/lib/jenkins/.kube/config"
        DEPLOYMENT_YAML = "k8s/deployment.yaml"
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

        stage('Build Docker Image for Minikube') {
            steps {
                script {
                    // Setează Docker să folosească daemon-ul Minikube
                    sh 'eval $(minikube docker-env)'

                    // Construiește imaginea Docker local în Minikube
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                    
                    // Debugging pentru imagini
                    sh 'docker images'
                }
            }
        }

        stage('Generate Deployment YAML') {
            steps {
                script {
                    // Creează directorul dacă nu există
                    sh 'mkdir -p k8s'

                    // Generează deployment.yaml dinamic
                    writeFile file: "${DEPLOYMENT_YAML}", text: """
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${KUBERNETES_DEPLOYMENT_NAME}
  namespace: ${KUBERNETES_NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${KUBERNETES_DEPLOYMENT_NAME}
  template:
    metadata:
      labels:
        app: ${KUBERNETES_DEPLOYMENT_NAME}
    spec:
      containers:
        - name: ${KUBERNETES_DEPLOYMENT_NAME}
          image: ${DOCKER_IMAGE}
          ports:
            - containerPort: 8080
"""
                    
                    // Debugging pentru conținutul fișierului
                    sh "cat ${DEPLOYMENT_YAML}"
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    // Setează contextul Kubernetes pe Minikube
                    sh 'kubectl config use-context minikube'

                    // Aplică deployment-ul generat
                    sh "kubectl apply -f ${DEPLOYMENT_YAML}"

                    // Verifică statusul deployment-ului
                    sh "kubectl rollout status deployment/${KUBERNETES_DEPLOYMENT_NAME}"
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
