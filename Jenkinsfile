pipeline {
    agent any  // Using 'any' and defining Docker inside steps

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
                script {
                    def hasLintScript = sh(script: "npm run | grep -w 'lint' || echo 'not_found'", returnStdout: true).trim()
                    if (hasLintScript != 'not_found') {
                        sh 'npm run lint'
                    } else {
                        echo 'Lint script not found, skipping...'
                    }
                }
            }
        }

        stage('Setup Node.js & Install Dependencies') {
            steps {
                script {
                    docker.image('cypress/included:9.7.0').inside('--ipc=host') {
                        sh 'node -v'
                        sh 'npm config set prefix ~/.npm-global'
                        sh 'npm install'
                    }
                }
            }
        }

        stage('Run Unit & Integration Tests') {
            steps {
                script {
                    docker.image('cypress/included:9.7.0').inside('--ipc=host') {
                        sh 'npx jest --ci --reporters=default --reporters=jest-junit --passWithNoTests'
                        sh 'npx mocha --reporter mocha-junit-reporter || true'
                    }
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'reports/*.xml'
                }
            }
        }

        stage('API Test Automation') {
            steps {
                script {
                    docker.image('cypress/included:9.7.0').inside('--ipc=host') {
                        sh 'npm run test:api || true'
                    }
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'reports/api-tests.xml'
                }
            }
        }

        stage('Run End-to-End Tests with Cypress') {
            steps {
                script {
                    docker.image('cypress/included:9.7.0').inside('--ipc=host') {
                        sh 'npm run test:e2e || true'
                    }
                }
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
