pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    parameters {
        string(
            name: 'SSH_ALLOWED_CIDR',
            defaultValue: '138.199.53.249/32',
            description: 'Your current public IP with /32 for SSH access'
        )
    }

    environment {
        IMAGE_NAME = 'ghcr.io/s-a-r-a123/devops-project'
        TF_DIR = 'C:\\JenkinsTerraform'
        AWS_DEFAULT_REGION = 'ap-southeast-2'
        TF_IN_AUTOMATION = 'true'
    }

    stages {
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

        stage('Prepare Persistent Terraform Directory') {
            steps {
                bat '''
                    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $src=Join-Path $env:WORKSPACE 'terraform'; $dst=$env:TF_DIR; if (!(Test-Path (Join-Path $dst 'terraform.tfstate'))) { throw 'Existing Terraform state is missing. Refusing to initialize a new state.' }; if (!(Test-Path (Join-Path $src 'main.tf'))) { throw 'Terraform configuration not found in workspace.' }; Copy-Item (Join-Path $src '*.tf') $dst -Force; Copy-Item (Join-Path $src 'userdata.sh') $dst -Force; Copy-Item (Join-Path $src '.terraform.lock.hcl') $dst -Force"
                '''
            }
        }

        stage('Verify AWS and Terraform State') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-credentials',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    bat '''
                        aws sts get-caller-identity
                        terraform -chdir=%TF_DIR% --version
                        terraform -chdir=%TF_DIR% init -input=false
                        terraform -chdir=%TF_DIR% validate
                        terraform -chdir=%TF_DIR% state list
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-credentials',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    bat '''
                        if "%SSH_ALLOWED_CIDR%"=="" exit /b 1
                        terraform -chdir=%TF_DIR% plan -input=false -lock-timeout=60s -var="ghcr_image=%IMAGE_NAME%:latest" -var="ssh_allowed_cidr=%SSH_ALLOWED_CIDR%" -out=tfplan
                        if errorlevel 1 exit /b 1
                        terraform -chdir=%TF_DIR% show -no-color tfplan
                    '''
                }
            }
        }

        stage('Approve Terraform Apply') {
            steps {
                input message: 'Review the Terraform plan in the build log. Apply these infrastructure changes?', ok: 'Approve Apply'
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-credentials',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    bat 'terraform -chdir=%TF_DIR% apply -input=false -lock-timeout=60s tfplan'
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