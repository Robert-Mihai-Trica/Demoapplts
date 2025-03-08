pipeline {
    agent any
 
    environment {
        DOCKER_IMAGE = "tricarobert/myapp:${env.BUILD_ID}"
        KUBERNETES_NAMESPACE = "default"
        KUBERNETES_DEPLOYMENT_NAME = "demoapp"
        KUBECONFIG = "/var/lib/jenkins/.kube/config"
        DEPLOYMENT_YAML = "" // Initialize as empty, will be set in a stage
    }
 
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Robert-Mihai-Trica/Demoapplts.git'
            }
        }
 
        stage('Set Deployment YAML Path') {
            steps {
                script {
                    env.DEPLOYMENT_YAML = "${env.WORKSPACE}/deployment.yaml"
                }
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
                    sh 'eval $(minikube docker-env) && docker build -t ${DOCKER_IMAGE} .'
                    sh 'docker images'
                }
            }
        }
 
        stage('Deploy to Minikube') {
            steps {
                script {
                    sh 'kubectl config use-context minikube'
                    // Replace variables in the deployment.yaml file
                    sh "envsubst < ${DEPLOYMENT_YAML} | kubectl apply -f -"
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
