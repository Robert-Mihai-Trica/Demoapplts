pipeline {
    agent any  // Rulează pe agentul cu Docker sau pe orice agent disponibil

    environment {
        DOCKER_IMAGE = "docker.io/tricarobert/demoapp:latest"
        K8S_DEPLOYMENT = "aplicatie"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Robert-Mihai-Trica/Demoapplts.git' // Înlocuiește cu repo-ul tău
            }
        }

        stage('Install kubectl') {
    steps {
        script {
            // Instalează kubectl în containerul Jenkins
            sh '''
                apt-get update && apt-get install -y apt-transport-https curl gnupg lsb-release
                curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | tee /etc/apt/trusted.gpg.d/kubernetes.asc
                DISTRO=$(lsb_release -c | awk '{ print $2 }')
                echo "deb https://apt.kubernetes.io/ kubernetes-$DISTRO main" | tee /etc/apt/sources.list.d/kubernetes.list
                apt-get update && apt-get install -y kubectl
            '''
        }
    }
}


        stage('Build & Test') {
            steps {
                script {
                    // Construim imaginea Docker pentru aplicație
                    sh 'docker build --target build -t aplicatie-build .'
                    
                    // Rulăm testele în imaginea de build
                    sh 'docker run --rm aplicatie-build mvn test'
                }
            }
        }

        stage('Build Final Image') {
            steps {
                script {
                    // Construim imaginea finală a aplicației
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    // Etichetăm și încărcăm imaginea pe Docker Hub
                    sh 'docker tag ${DOCKER_IMAGE} ${DOCKER_IMAGE}'
                    sh 'docker login -u "tricarobert" -p "Crush1234"'
                    sh 'docker push ${DOCKER_IMAGE}'
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    // Configurăm kubectl pentru Minikube
                    sh 'kubectl config use-context minikube'
                    
                    // Ștergem deployment-ul existent și aplicăm noul fișier de deployment
                    sh 'kubectl delete deployment $K8S_DEPLOYMENT --ignore-not-found=true'
                    sh 'kubectl apply -f k8s/deployment.yaml'
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    // Verificăm starea pod-urilor și serviciilor în Minikube
                    sh 'kubectl get pods'
                    sh 'kubectl get services'
                }
            }
        }
    }
}
