pipeline {
    agent any

    environment {
        NEXUS_HOST = "http://localhost:8081"
        NEXUS_REPO = "ml-models"
        CONFIG_FILE = "config.json"
        MODEL_CACHE_DIR = "/var/jenkins_home/model_cache"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Read Model Name') {
            steps {
                script {
                    def config = readJSON file: "${CONFIG_FILE}"
                    env.MODEL_NAME = config.model_name
                    env.MODEL_URL = "${NEXUS_HOST}/repository/${NEXUS_REPO}/${env.MODEL_NAME}.tar.gz"
                }
            }
        }

        stage('Check Model in Nexus') {
            steps {
                script {
                    def response = sh(script: "curl -s -o /dev/null -w \"%{http_code}\" ${env.MODEL_URL}", returnStdout: true).trim()
                    if (response != "200") {
                        error("Model ${env.MODEL_NAME} not found in Nexus!")
                    }
                }
            }
        }

        stage('Download Model') {
            steps {
                sh """
                    mkdir -p ${MODEL_CACHE_DIR}
                    wget -O ${MODEL_CACHE_DIR}/${env.MODEL_NAME}.tar.gz ${env.MODEL_URL}
                    tar -xzf ${MODEL_CACHE_DIR}/${env.MODEL_NAME}.tar.gz -C model/
                """
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Run Chatbot') {
            steps {
                sh 'nohup python app.py &'
            }
        }
    }
}
