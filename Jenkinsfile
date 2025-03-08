
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "tricarobert/myapp:${env.BUILD_ID}"
        KUBERNETES_NAMESPACE = "default"
        KUBERNETES_DEPLOYMENT_NAME = "demoapp"
        KUBECONFIG = "/var/lib/jenkins/.kube/config"
        // Calea completă către fișierul YAML
        DEPLOYMENT_YAML = "deployment.yaml"
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

        stage('Build Docker Image for Minikube123') {
            steps {
                script {
                    sh 'eval $(minikube docker-env) && docker build -t ${DOCKER_IMAGE} .'
                    sh 'docker images'
                }
            }
        }

        stage('Generate Deployment YAML') {
            steps {
                script {
                    // Se asigură că directorul `k8s` există
                    sh 'mkdir -p k8s'
                    writeFile file: DEPLOYMENT_YAML, text: """
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
                    // Verifică conținutul fișierului YAML generat
                    sh "cat ${DEPLOYMENT_YAML}"
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    sh 'kubectl config use-context minikube'
                    // Aplică fișierul YAML folosind calea completă
                    sh "kubectl apply -f ${DEPLOYMENT_YAML}"
                    sh 'kubectl get deployments'

                    def deploymentExists = sh(script: "kubectl get deployment ${KUBERNETES_DEPLOYMENT_NAME} --ignore-not-found", returnStdout: true).trim()

                    if (deploymentExists) {
                        sh "kubectl set image deployment/${KUBERNETES_DEPLOYMENT_NAME} ${KUBERNETES_DEPLOYMENT_NAME}=${DOCKER_IMAGE}"
                        sh "kubectl rollout status deployment/${KUBERNETES_DEPLOYMENT_NAME}"
                    } else {
                        echo "⚠️ Deployment-ul nu a fost creat! Verifică YAML-ul!"
                    }
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
