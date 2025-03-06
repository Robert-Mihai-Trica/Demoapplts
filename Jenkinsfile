pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'hhttps://github.com/Robert-Mihai-Trica/Demoapplts.git'
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

        stage('Results') {
            steps {
                junit '**/target/surefire-reports/*.xml'
            }
        }
    }
}

