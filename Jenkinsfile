pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
        timeout(time: 15, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    environment {
        IMAGE_NAME = 'jenkins-enterprise-cicd'
        IMAGE_TAG = "build-${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git --version'
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

        stage('Build Docker Image') {
            steps {
                sh '''
                    set -eu
                    docker build --pull \
                      --label "org.opencontainers.image.revision=${GIT_COMMIT}" \
                      --tag "${IMAGE_NAME}:${IMAGE_TAG}" .
                '''
            }
        }

        stage('Container Smoke Test') {
            steps {
                sh '''
                    set -eu

                    CONTAINER_NAME="jenkins-ci-smoke-${BUILD_NUMBER}"
                    PORT=$((18000 + BUILD_NUMBER % 1000))

                    cleanup() {
                      docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
                    }
                    trap cleanup EXIT

                    docker run --detach \
                      --name "$CONTAINER_NAME" \
                      --publish "127.0.0.1:${PORT}:8000" \
                      "${IMAGE_NAME}:${IMAGE_TAG}"

                    ATTEMPT=0
                    until curl --fail --silent "http://127.0.0.1:${PORT}/health"; do
                      ATTEMPT=$((ATTEMPT + 1))
                      if [ "$ATTEMPT" -ge 20 ]; then
                        echo "Container health endpoint did not become ready."
                        docker logs "$CONTAINER_NAME" || true
                        exit 1
                      fi
                      sleep 2
                    done

                    echo
                    curl --fail --silent "http://127.0.0.1:${PORT}/version"
                    echo
                '''
            }
        }
    }

    post {
        success {
            echo 'CI pipeline completed successfully.'
        }
        failure {
            echo 'CI pipeline failed. Review the failed stage logs.'
        }
        always {
            echo 'Pipeline execution finished.'
        }
    }
}
