pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t devops-project:%BUILD_NUMBER% .'
            }
        }

        stage('Test Container') {
            steps {
                bat 'docker rm -f devops-project-test 2>NUL || exit /b 0'
                bat 'docker run -d --name devops-project-test -p 18080:80 devops-project:%BUILD_NUMBER%'
                bat 'curl.exe --fail http://localhost:18080'
            }
        }
    }

    post {
        always {
            bat 'docker rm -f devops-project-test 2>NUL || exit /b 0'
        }
    }
}