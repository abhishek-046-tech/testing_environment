pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/your-repo.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Run Unit & Integration Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Run Cypress Tests') {
            steps {
                sh 'npm run cypress:run'
            }
        }

        stage('Run API Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Publish Test Reports') {
            steps {
                junit 'reports/*.xml'  // Ensure your testing frameworks output JUnit format reports
                archiveArtifacts artifacts: 'coverage/**', fingerprint: true
            }
        }
    }

    post {
        always {
            mail to: 'qa-team@example.com',
                 subject: "Test Pipeline Results",
                 body: "Check Jenkins for detailed results."
        }
    }
}

