pipeline {
    agent { docker { image 'node:6.3' } }
    stages {
        stage('build') {
            steps {
                sh 'sudo bundle install'
		sh 'fastlane beta'
            }
        }
    }
}