pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
        timeout(time: 40, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '30'))
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        AWS_REGION = 'ap-south-1'
        ECR_REPOSITORY_NAME = 'cloudcart-dev-api'
        EKS_CLUSTER_NAME = 'cloudcart-dev-eks'
        IMAGE_NAME = 'cloudcart-api'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.IMAGE_TAG = sh(
                        script: 'git rev-parse HEAD',
                        returnStdout: true
                    ).trim()
                    echo "Building immutable image tag: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Unit Tests') {
            steps {
                sh '''
                    set -eu
                    python3 --version
                    python3 -m venv .venv
                    .venv/bin/python -m pip install --upgrade pip
                    .venv/bin/python -m pip install -r requirements-dev.txt
                    .venv/bin/python -m pytest -v --junitxml=pytest-results.xml
                '''
            }
            post {
                always {
                    junit testResults: 'pytest-results.xml', allowEmptyResults: true
                }
            }
        }

        stage('Verify AWS Identity') {
            steps {
                sh '''
                    set -eu
                    aws --version
                    aws sts get-caller-identity
                    aws ecr describe-repositories \
                      --region "$AWS_DEFAULT_REGION" \
                      --repository-names "$ECR_REPOSITORY_NAME"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    set -eu
                    docker build --pull \
                      --label "org.opencontainers.image.revision=${IMAGE_TAG}" \
                      --tag "${IMAGE_NAME}:${IMAGE_TAG}" .
                '''
            }
        }

        stage('Push Image to ECR') {
            when {
                expression {
                    env.BRANCH_NAME == 'main' ||
                    env.GIT_BRANCH == 'origin/main' ||
                    env.GIT_BRANCH == 'main'
                }
            }
            steps {
                script {
                    env.ECR_REPOSITORY_URI = sh(
                        script: '''
                            aws ecr describe-repositories \
                              --region "$AWS_DEFAULT_REGION" \
                              --repository-names "$ECR_REPOSITORY_NAME" \
                              --query 'repositories[0].repositoryUri' \
                              --output text
                        ''',
                        returnStdout: true
                    ).trim()
                }

                sh '''
                    set -eu
                    aws ecr get-login-password \
                      --region "$AWS_DEFAULT_REGION" |
                      docker login \
                        --username AWS \
                        --password-stdin "$ECR_REPOSITORY_URI"

                    docker tag "${IMAGE_NAME}:${IMAGE_TAG}" \
                      "${ECR_REPOSITORY_URI}:${IMAGE_TAG}"

                    docker push "${ECR_REPOSITORY_URI}:${IMAGE_TAG}"
                '''
            }
        }

        stage('Deploy to EKS') {
            when {
                expression {
                    env.BRANCH_NAME == 'main' ||
                    env.GIT_BRANCH == 'origin/main' ||
                    env.GIT_BRANCH == 'main'
                }
            }
            steps {
                sh '''
                    set -eu
                    : "${ECR_REPOSITORY_URI:?ECR repository URI missing}"

                    chmod +x scripts/deploy-to-eks.sh
                    ./scripts/deploy-to-eks.sh
                '''
            }
        }
    }

    post {
        success {
            echo 'CloudCart pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Review the failed stage and its logs.'
        }
        always {
            echo 'Jenkins pipeline execution finished.'
        }
    }
}
