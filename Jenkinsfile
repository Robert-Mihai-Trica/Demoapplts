pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "myapp:${env.BUILD_ID}" // Numele imaginii Docker
        DOCKER_REGISTRY = "docker.io" // Registry-ul Docker
        KUBERNETES_NAMESPACE = "default" // Namespace-ul Kubernetes
        KUBERNETES_DEPLOYMENT_NAME = "demoapp" // Numele deployment-ului în Kubernetes
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

        stage('Build Docker Image') {
            steps {
                script {
                    // Construirea imaginii Docker folosind Dockerfile-ul existent
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Autentificare în Docker Registry folosind credentialele Jenkins
                    withCredentials([usernamePassword(credentialsId: 'Docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin ${DOCKER_REGISTRY}"
                    }
                    // Împingerea imaginii în Docker Registry
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Asigură-te că ai configurat kubectl pentru a lucra cu clusterul tău Kubernetes
                    sh 'kubectl config use-context my-k8s-cluster'  // Folosește contextul corect pentru Kubernetes
                    // Actualizează deployment-ul Kubernetes cu noua imagine Docker
                    sh """
                    kubectl set image deployment/${KUBERNETES_DEPLOYMENT_NAME} ${KUBERNETES_DEPLOYMENT_NAME}=${DOCKER_REGISTRY}/${DOCKER_IMAGE}
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
            // Curăță resursele Docker
            sh 'docker system prune -f'
        }
    }
}
