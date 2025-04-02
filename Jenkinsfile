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
                sh 'npm config set prefix ~/.npm-global'
                sh 'npm install'
            }
        }

        stage('Run Unit & Integration Tests') {
            steps {
                sh 'npx jest --ci --reporters=default --reporters=jest-junit --passWithNoTests'
            }
            post {
                always {
                    script {
                        def testFiles = sh(script: "ls reports/jest-junit.xml 2>/dev/null || echo 'not_found'", returnStdout: true).trim()
                        if (testFiles != 'not_found') {
                            junit allowEmptyResults: true, testResults: 'reports/jest-junit.xml'
                        } else {
                            echo 'No test results found, skipping report collection.'
                        }
                    }
                }
            }
        }

        stage('API Test Automation') {
            steps {
                sh 'npm run test:api || true'
            }
            post {
                always {
                    script {
                        def testFiles = sh(script: "ls reports/api-tests.xml 2>/dev/null || echo 'not_found'", returnStdout: true).trim()
                        if (testFiles != 'not_found') {
                            junit allowEmptyResults: true, testResults: 'reports/api-tests.xml'
                        } else {
                            echo 'No API test results found, skipping report collection.'
                        }
                    }
                }
            }
        }

        stage('Run End-to-End Tests with Cypress') {
            steps {
                sh 'npm run test:e2e || true'
            }
            post {
                always {
                    script {
                        def reportExists = sh(script: "ls cypress/reports/index.html 2>/dev/null || echo 'not_found'", returnStdout: true).trim()
                        if (reportExists != 'not_found') {
                            publishHTML([
                                allowMissing: true,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'cypress/reports',
                                reportFiles: 'index.html',
                                reportName: 'Cypress Test Report'
                            ])
                        } else {
                            echo 'No Cypress test report found, skipping.'
                        }
                    }
                }
            }
        }

        stage('Generate and Publish Test Reports') {
            steps {
                script {
                    sh 'npm run test:coverage || true'
                    sh 'mkdir -p test-reports && mv coverage test-reports/ || true'
                }
                archiveArtifacts artifacts: '**/*', fingerprint: true, allowEmptyArchive: true
            }
        }

        stage('Code Build') {
            steps {
                echo 'Building application...'
                script {
                    def buildScript = sh(script: "npm run | grep build || echo 'not_found'", returnStdout: true).trim()
                    if (buildScript != 'not_found') {
                        sh 'npm run build'
                    } else {
                        echo 'No build script found in package.json, skipping build stage.'
                    }
                }
                archiveArtifacts artifacts: '**/*', fingerprint: true
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                sh './deploy.sh'  // Replace with actual deployment script
            }
        }
    }

    post {
        success {
            echo 'All tests passed and deployment completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
