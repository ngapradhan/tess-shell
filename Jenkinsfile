pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Checkout the repository containing the script
                git 'https://github.com/ngapradhan/tess-shell.git' 
            }
        }

        stage('Run Shell Script') {
            steps {
                script {
                    // Run the shell script directly from the repository
                    sh 'chmod +x test.sh'
                    sh './test.sh'  // Adjust the path to the script in the repo
                }
            }
        }
    }
}
