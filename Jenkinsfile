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
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
        JENKINS_API_TOKEN = credentials("e9d62095-3aa4-4ea1-89f1-78b8bf380ebb")
        SONAR_QUBE_TOKEN = credentials("f006ec77-b5f4-4ac2-82db-1a0968fb4c0d")
    }
    
    stages {
        stage("Cleanup Workspace") {
            steps {
                cleanWs()
            }
        }
    
        stage("Checkout from SCM") {
            steps {
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/Robert-Mihai-Trica/DemoApp.git'
            }
        }

        stage("Build Application") {
            steps {
                bat "mvn clean package"
            }
        }

        stage("Test Application") {
            steps {
                bat "mvn test"
            }
        }
        
         stage('Sonarqube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('SonarQube') {
                        bat "mvn sonar:sonar -Dsonar.login=${env.SONAR_QUBE_TOKEN}"
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

        stage("Build & Push Docker Image") {
            steps {
                script {
                    docker.withRegistry('', DOCKER_CREDENTIAL_ID) {
                        docker_image = docker.build "${IMAGE_NAME}"
                    }

                    docker.withRegistry('', DOCKER_CREDENTIAL_ID) {
                        docker_image.push("${IMAGE_TAG}")
                        docker_image.push('latest')
                    }
                }
            }
        }

        stage("Trivy Scan") {
            steps {
                script {
                    bat 'docker run --rm -v %CD%:/workspace -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image %IMAGE_NAME%:%IMAGE_TAG% --no-progress --scanners vuln --exit-code 0 --severity HIGH,CRITICAL --format table'
                }
            }
        }

        stage ('Cleanup Artifacts') {
            steps {
                script {
                    bat "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || echo Image ${IMAGE_NAME}:${IMAGE_TAG} not found"
                    bat "docker rmi ${IMAGE_NAME}:latest || echo Image ${IMAGE_NAME}:latest not found"
                }
            }
        }

        /* stage("Trigger CD Pipeline") {
            steps {
                script {
                    bat "curl -v -k --user admin:%JENKINS_API_TOKEN% -X POST -H 'cache-control: no-cache' -H 'content-type: application/x-www-form-urlencoded' --data 'IMAGE_TAG=%IMAGE_TAG%' 'https://jenkins.dev.dman.cloud/job/gitops-complete-pipeline/buildWithParameters?token=gitops-token'"
                }
            }
        } */
    }

    /* post {
        failure {
            emailext body: '''${SCRIPT, template="groovy-html.template"}''', 
                    subject: "${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - Failed", 
                    mimeType: 'text/html', to: "trica.robert@gmail.com"
        }
        success {
            emailext body: '''${SCRIPT, template="groovy-html.template"}''', 
                    subject: "${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - Successful", 
                    mimeType: 'text/html', to: "trica.robert@gmail.com"
        }      
    } */
}
