pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Checkout the repository containing the script
                git 'https://your-repository-url.git'  // Replace with your repo URL
            }
        }

        stage('Run Shell Script') {
            steps {
                script {
                    // Run the shell script directly from the repository
                    sh './path/to/your/script.sh'  // Adjust the path to the script in the repo
                }
            }
        }
    }

    post {
        always {
            // Cleanup, if necessary
            echo 'Pipeline execution completed.'
        }
    }
}
