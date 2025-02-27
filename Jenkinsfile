pipeline {
    agent any
    tools {
        jdk 'Java17'
        maven 'Maven3'
    }

    environment {
        APP_NAME = "DemoApp"
        RELEASE = "1.0.0"
        DOCKER_USER = "tricarobert"
        DOCKER_CREDENTIAL_ID = '6746df68-59b1-4588-ab5a-72e9bd0fd0be' 
        IMAGE_NAME = "${DOCKER_USER}/${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${env.BUILD_NUMBER}"
        JENKINS_API_TOKEN = credentials("e9d62095-3aa4-4ea1-89f1-78b8bf380ebb")
        SONAR_QUBE_TOKEN = credentials("f006ec77-b5f4-4ac2-82db-1a0968fb4c0d")
        REPO_URL = 'https://github.com/Robert-Mihai-Trica/DemoApp.git'
        BRANCH = 'main'
        DEPLOYMENT_YAML = 'k8s/deployment.yaml'
    }

    stages {
        stage("Cleanup Workspace") {
            steps {
                cleanWs()
            }
        }
    
        stage("Checkout from SCM") {
            steps {
                git branch: "${BRANCH}", credentialsId: 'github', url: "${REPO_URL}"
            }
        }

        stage("Build & Test") {
            steps {
                sh 'mvn clean package'
                sh 'mvn test'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Sonarqube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('SonarQube') {
                        sh "mvn sonar:sonar -Dsonar.login=${SONAR_QUBE_TOKEN}"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false
                }
            }
        }

        stage('Load Image into Minikube') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_CREDENTIAL_ID) {
                        docker_image = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                        docker_image.push("${IMAGE_TAG}")
                        docker_image.push('latest')
                    }
                }
                sh 'minikube image load ${IMAGE_NAME}:${IMAGE_TAG}'
            }
        }

        stage('Deploy to Minikube') {
            steps {
                sh 'kubectl apply -f ${DEPLOYMENT_YAML}'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh 'docker run --rm -v $(pwd):/workspace -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image ${IMAGE_NAME}:${IMAGE_TAG} --no-progress --scanners vuln --exit-code 0 --severity HIGH,CRITICAL --format table'
            }
        }

        stage('Verify Deployment') {
            steps {
                sh 'kubectl get pods'
            }
        }

        stage('Cleanup Artifacts') {
            steps {
                sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || echo Image ${IMAGE_NAME}:${IMAGE_TAG} not found"
                sh "docker rmi ${IMAGE_NAME}:latest || echo Image ${IMAGE_NAME}:latest not found"
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            emailext body: '''${SCRIPT, template="groovy-html.template"}''', 
                    subject: "${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - Failed", 
                    mimeType: 'text/html', 
                    to: "trica.robert@gmail.com"
        }
    }
}

