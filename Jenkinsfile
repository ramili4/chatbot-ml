pipeline {
    agent any

    environment {
        NEXUS_HOST       = "http://localhost:8081"
        NEXUS_REPO       = "docker-hosted"
        CONFIG_FILE      = "config.json"
        MODEL_CACHE_DIR  = "/var/jenkins_home/model_cache"
        DOCKER_REGISTRY  = "localhost:8082"  
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

                    // Test connection
                    def statusCode = sh(script: "curl -s -o /dev/null -w \"%{http_code}\" ${nexusUrl}", returnStdout: true).trim()
                    
                    if (statusCode == "200") {
                        echo "✅ Model '${env.MODEL_NAME}' found in Nexus!"
                    } else {
                        error "❌ Model '${env.MODEL_NAME}' not found in Nexus! Status: ${statusCode}"
                    }
                }
            }
        }

       stage('Download Model') {
            steps {
                script {
                    echo "⬇️ Pulling model image from Nexus..."
        
                    def pullStatus = sh(script: """
                        docker pull ${env.MODEL_IMAGE}
                    """, returnStatus: true)
        
                    if (pullStatus != 0) {
                        error "❌ Failed to pull image ${env.MODEL_IMAGE}"
                    }
        
                    echo "✅ Model image pulled successfully!"
                }
            }
        }


      stage('Install Dependencies') {
            steps {
                script {
                    echo "📦 Setting up virtual environment..."
                    sh '''
                        python3 -m venv venv
                        . venv/bin/activate
                        pip install --no-cache-dir -r requirements.txt
                    '''
                }
            }
        }




        stage('Run Chatbot') {
            steps {
                script {
                    echo "🤖 Starting chatbot..."
                    sh "nohup python app.py > chatbot.log 2>&1 &"
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
