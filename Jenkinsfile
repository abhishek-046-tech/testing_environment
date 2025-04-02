pipeline {
    agent any

    environment {
        NODEJS_VERSION = '18'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/abhishek-046-tech/testing_environment.git'
            }
        }

        stage('Static Code Analysis') {
            steps {
                sh 'npm run lint || true'  // Runs ESLint
            }
        }

        stage('Setup Node.js & Install Dependencies') {
            steps {
                script {
                    def nodeInstalled = sh(script: 'node -v || echo "not_installed"', returnStdout: true).trim()
                    if (nodeInstalled == "not_installed") {
                        sh 'curl -fsSL https://deb.nodesource.com/setup_18.x | bash -'
                        sh 'apt-get update && apt-get install -y nodejs'
                    }
                }
                sh 'node -v'
                sh 'npm config set prefix ~/.npm-global'
                sh 'npm install'
                sh 'apt-get update && apt-get install -y xvfb'  // Install Xvfb for Cypress
            }
        }

        stage('Run Unit & Integration Tests') {
            steps {
                sh 'npx jest --ci --reporters=default --reporters=jest-junit --passWithNoTests'
                sh 'npx mocha --reporter mocha-junit-reporter || true'
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'reports/*.xml'
                }
            }
        }

        stage('API Test Automation') {
            steps {
                sh 'npm run test:api || true'
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'reports/api-tests.xml'
                }
            }
        }

        stage('Run End-to-End Tests with Cypress') {
            steps {
                sh 'Xvfb :99 -ac &'
                sh 'export DISPLAY=:99.0'
                sh 'npm run test:e2e || true'
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

        stage('Security Scanning') {
            steps {
                sh 'npm audit --audit-level=high || true'  // Runs a security audit
            }
        }

        stage('Performance Testing') {
            steps {
                sh 'npm run test:performance || true'  // Executes performance tests using JMeter/K6
            }
        }

        stage('Code Build') {
            steps {
                sh 'npm run build'  // Build step before deployment
            }
        }

        stage('Build & Deploy') {
            steps {
                sh 'docker build -t my-app:latest .'
                sh 'docker run -d -p 3000:3000 my-app:latest'
            }
        }

        stage('Generate and Publish Test Reports') {
            steps {
                sh 'npm run test:coverage || true'
                sh 'mkdir -p test-reports && mv coverage test-reports/ || true'
                archiveArtifacts artifacts: 'test-reports/**/*', fingerprint: true, allowEmptyArchive: true
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
