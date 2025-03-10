pipeline {
    agent any

    environment {
        NEXUS_HOST       = "http://localhost:8081"
        NEXUS_REPO       = "docker-hosted"
        CONFIG_FILE      = "config.json"
        DOCKER_REGISTRY  = "localhost:8082"
        APP_IMAGE        = "chatbot-app"
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    echo "📥 Checking out the repository..."
                    checkout scm
                }
            }
        }

        stage('Read Model Name') {
            steps {
                script {
                    def config = readJSON file: CONFIG_FILE
                    env.MODEL_NAME  = config.model_name
                    env.MODEL_TAG   = config.model_tag ?: "latest"
                    env.MODEL_IMAGE = "${DOCKER_REGISTRY}/${NEXUS_REPO}/${env.MODEL_NAME}:${env.MODEL_TAG}"

                    echo "🔍 Model Name: ${env.MODEL_NAME}"
                    echo "🔖 Model Tag: ${env.MODEL_TAG}"
                    echo "📦 Model Image: ${env.MODEL_IMAGE}"
                }
            }
        }

        stage('Run Chatbot') {
            steps {
                script {
                    echo "🐳 Pulling chatbot image from Nexus..."
                    sh "docker pull ${env.MODEL_IMAGE}"

                    echo "🤖 Running chatbot inside a container..."
                    sh """
                        docker rm -f chatbot-container || true
                        docker run -d -p 7860:7860 --name chatbot-container ${env.MODEL_IMAGE}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline completed successfully!"
        }
        failure {
            echo "🚨 Pipeline failed!"
        }
    }
}
