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
                    steps.echo "I am inside feature branch"
                    sh 'ls -l'  // Adjust the path to the script in the repo
                }
            }
        }
    }
}
