pipeline {
    agent any

    environment {
        NODEJS_VERSION = '18'  // Adjust as needed
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/abhishek-046-tech/testing_environment.git'
            }
        }

        stage('Setup Node.js & Install Dependencies') {
            steps {
                script {
                    def nodeInstalled = sh(script: 'node -v || echo "not_installed"', returnStdout: true).trim()
                    if (nodeInstalled == "not_installed") {
                        sh 'curl -fsSL https://deb.nodesource.com/setup_18.x | bash -'
                        sh 'apt-get install -y nodejs'
                    }
                }
                sh 'node -v'
                sh 'npm install'
            }
        }

        stage('Run Unit & Integration Tests') {
            steps {
                sh 'npm run test:unit'  // Example Jest or Mocha test command
                sh 'npm run test:integration'
            }
            post {
                always {
                    junit 'reports/unit-tests.xml'
                }
            }
        }

        stage('API Test Automation') {
            steps {
                sh 'npm run test:api'  // Example using Postman or Supertest
            }
            post {
                always {
                    junit 'reports/api-tests.xml'
                }
            }
        }

        stage('Run End-to-End Tests with Cypress') {
            steps {
                sh 'npm run test:e2e'  // Cypress test execution
            }
            post {
                always {
                    publishHTML([
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'cypress/reports',
                        reportFiles: 'index.html',
                        reportName: 'Cypress Test Report'
                    ])
                }
            }
        }

        stage('Generate and Publish Test Reports') {
            steps {
                script {
                    sh 'npm run test:coverage'  // Example command to generate coverage reports
                    sh 'mkdir -p test-reports && mv coverage test-reports/'  // Store coverage reports
                }
                archiveArtifacts artifacts: 'test-reports/**/*', fingerprint: true
            }
        }
    }

    post {
        success {
            echo 'All tests passed successfully!'
        }
        failure {
            echo 'Some tests failed. Check reports for details.'
        }
    }
}
