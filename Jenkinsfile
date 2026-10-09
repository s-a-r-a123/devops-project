pipeline {
    agent any

    environment {
        IMAGE_NAME = 'ghcr.io/s-a-r-a123/devops-project'
    }

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

        stage('Push to GHCR') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'ghcr-credentials',
                        usernameVariable: 'GHCR_USER',
                        passwordVariable: 'GHCR_TOKEN'
                    )
                ]) {
                    bat 'echo %GHCR_TOKEN%| docker login ghcr.io -u %GHCR_USER% --password-stdin'
                    bat 'docker tag devops-project:%BUILD_NUMBER% %IMAGE_NAME%:%BUILD_NUMBER%'
                    bat 'docker tag devops-project:%BUILD_NUMBER% %IMAGE_NAME%:latest'
                    bat 'docker push %IMAGE_NAME%:%BUILD_NUMBER%'
                    bat 'docker push %IMAGE_NAME%:latest'
                }
            }
        }
    }

    post {
        always {
            bat 'docker rm -f devops-project-test 2>NUL || exit /b 0'
        }
    }
}