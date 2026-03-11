pipeline {
    agent any

    stages {
        stage('Build and Push') {
            when { buildingTag() }
            steps {
                sh 'docker build -t shadowlands:5000/vertex-studio:${TAG_NAME} .'
                sh 'docker push shadowlands:5000/vertex-studio:${TAG_NAME}'
            }
        }
    }

    post {
        success {
            script {
                if (env.TAG_NAME) {
                    sh "docker rmi shadowlands:5000/vertex-studio:${TAG_NAME} || true"
                }
            }
        }
    }
}
