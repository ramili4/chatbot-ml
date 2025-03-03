pipeline {
    agent any

    environment {
        NEXUS_HOST = "http://localhost:8081"
        NEXUS_REPO = "docker-hosted"
        CONFIG_FILE = "config.json"
        MODEL_CACHE_DIR = "/var/jenkins_home/model_cache"
        DOCKER_REGISTRY = "http://localhost:8082"
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    echo "Checking out the repository..."
                    checkout scm
                }
            }
        }

        stage('Read Model Name') {
            steps {
                script {
                    def config = readJSON file: "${CONFIG_FILE}"
                    env.MODEL_NAME = config.model_name
                    env.MODEL_TAG = config.model_tag ?: "latest"
                    env.MODEL_IMAGE = "${DOCKER_REGISTRY}/${NEXUS_REPO}/${env.MODEL_NAME}:${env.MODEL_TAG}"

                    echo "Model Name: ${env.MODEL_NAME}"
                    echo "Model Tag: ${env.MODEL_TAG}"
                    echo "Model Image: ${env.MODEL_IMAGE}"
                }
            }
        }

        stage('Check Model in Nexus') {
            steps {
                script {
                    // Use the same model name from your environment variables 
                    def nexusUrl = "${DOCKER_REGISTRY}/v2/${NEXUS_REPO}/${env.MODEL_NAME}/tags/list"
                    echo "Checking model at: ${nexusUrl}"
                    
                    // Add debug output
                    sh "curl -v ${nexusUrl} || echo 'Connection failed'"
                    
                    def statusCode = sh(script: "curl -s -o /dev/null -w \"%{http_code}\" ${nexusUrl}", returnStdout: true).trim()
                    echo "Status code: ${statusCode}"
                    
                    if (statusCode != "200") {
                        error "❌ Model '${env.MODEL_NAME}' not found in Nexus! Status: ${statusCode}"
                    } else {
                        echo "✅ Model '${env.MODEL_NAME}' found in Nexus!"
                    }
                }
            }
        


        stage('Download Model') {
            steps {
                script {
                    echo "Pulling model image from Nexus..."
                    sh "docker pull ${env.MODEL_IMAGE}"
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    echo "Installing dependencies..."
                    sh 'pip install --no-cache-dir -r requirements.txt'
                }
            }
        }

        stage('Run Chatbot') {
            steps {
                script {
                    echo "Starting chatbot..."
                    sh "nohup python app.py > chatbot.log 2>&1 &"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}
