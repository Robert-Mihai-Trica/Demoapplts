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
                    sh 'eval $(minikube docker-env)'
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                    sh 'docker images'
                }
            }
        }

        stage('Generate Deployment YAML') {
            steps {
                script {
                    sh 'mkdir -p k8s'
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
                    sh "cat ${DEPLOYMENT_YAML}"
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    sh 'kubectl config use-context minikube'
                    sh """
                    kubectl get deployment ${KUBERNETES_DEPLOYMENT_NAME} || kubectl apply -f ${DEPLOYMENT_YAML}
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
