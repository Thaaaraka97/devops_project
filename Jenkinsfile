pipeline {
    agent any

    environment {
        // Define the Docker image name and tag
        DOCKER_IMAGE = "thaaaraka/custom_nginx_for_webapp" // Use the custom Nginx Docker image name
        DOCKER_TAG = "latest"
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-credentials')
        REMOTE_USER = "ubuntu"
        REMOTE_IP = "10.0.25.66"    
    }

    stages {
        stage('Checkout') {
            steps {
                // Fetch code from the GitHub repository
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], 
                         userRemoteConfigs: [[url: 'https://github.com/Thaaaraka97/devops_project.git']]])
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """ 
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    docker logout
                """
                
            }
        }

		stage('Test') {
            steps {
                sh """
                    docker run --name test_container -d -p 80:80 ${DOCKER_IMAGE}:${DOCKER_TAG}
                    sleep 10 // Give the container some time to start
                    curl -f http://localhost:8080 || exit 1 // Basic test to check if the web server is responding
                    docker stop test_container
                    docker rm test_container
                """
            }
        }

        stage('Deploy to Nginx Container') {
            steps { 
                // SSH into the target VM and deploy the Nginx container 
                // Stop and remove the existing Nginx container
                // Deploy the newly built custom Nginx Docker image as an Nginx container
                
                sh """                    
                    ssh ${REMOTE_USER}@${REMOTE_IP} '                    
                        docker stop mynginx || true; \
                        docker rm mynginx || true; \
                        
                        echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin; \
                        docker pull ${DOCKER_IMAGE}:${DOCKER_TAG}; \
        
                        docker run -d -p 80:80 --name mynginx ${DOCKER_IMAGE}:${DOCKER_TAG}; \
                        docker logout; \
                        exit 0; \
                    '
                """
            }
        }
    }

    post {
        
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
