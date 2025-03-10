pipeline {
    agent any

    environment {
        NEXUS_HOST       = "http://localhost:8081"
        NEXUS_REPO       = "docker-hosted"
        CONFIG_FILE      = "config.json"
        MODEL_CACHE_DIR  = "/var/jenkins_home/model_cache"
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

        stage('Check Model in Nexus') {
            steps {
                script {
                    def nexusUrl = "http://${DOCKER_REGISTRY}/v2/${NEXUS_REPO}/${env.MODEL_NAME}/tags/list"
                    echo "🔎 Checking model in Nexus at: ${nexusUrl}"

                    def statusCode = sh(script: "curl -s -o /dev/null -w \"%{http_code}\" ${nexusUrl}", returnStdout: true).trim()
                    if (statusCode == "200") {
                        echo "✅ Model '${env.MODEL_NAME}' found in Nexus!"
                    } else {
                        error "❌ Model '${env.MODEL_NAME}' not found in Nexus! Status: ${statusCode}"
                    }
                }
            }
        }

        stage('Extract Model from Image') {
            steps {
                script {
                    echo "📦 Extracting model from container..."
                    sh """
                        docker pull ${env.MODEL_IMAGE}
                        CONTAINER_ID=\$(docker create ${env.MODEL_IMAGE})
                        docker cp \${CONTAINER_ID}:/app/model/model.pth ${MODEL_CACHE_DIR}/model.pth
                        docker rm \${CONTAINER_ID}
                    """
                }
            }
        }

        stage('Build Chatbot Image') {
            steps {
                script {
                    echo "🐳 Building chatbot Docker image..."
                    sh """
                        docker build -t ${APP_IMAGE}:latest --build-arg MODEL_CACHE_DIR=${MODEL_CACHE_DIR} .
                    """
                }
            }
        }

        stage('Run Chatbot') {
            steps {
                script {
                    echo "🤖 Running chatbot inside a container..."
                    sh """
                        docker run -d -p 7860:7860 --name chatbot-container ${APP_IMAGE}:latest
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
