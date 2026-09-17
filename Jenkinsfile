pipeline {
    agent any

    tools {
        maven 'Maven'
    }

    environment {
        DOCKER_IMAGE_BE = 'ballasandeep17/task-manager-backend'
        DOCKER_IMAGE_FE = 'ballasandeep17/task-manager-frontend'
        DOCKER_TAG = "${BUILD_NUMBER}"

        FE_REPO = 'https://github.com/Sandeepsriramulu/task-manager-frontend.git'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Backend') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    sh """
                        docker build \
                        -t ${DOCKER_IMAGE_BE}:${DOCKER_TAG} \
                        -t ${DOCKER_IMAGE_BE}:latest .
                    """

                    sh """
                        rm -rf frontend-build
                        git clone ${FE_REPO} frontend-build
                    """

                    sh """
                        docker build -t ${DOCKER_IMAGE_FE}:${DOCKER_TAG} \
                        -t ${DOCKER_IMAGE_FE}:latest \
                        -f- frontend-build <<'EOF'
FROM node:18-alpine AS builder
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
EOF
                    """
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login \
                        -u "$DOCKER_USER" --password-stdin

                        docker push ${DOCKER_IMAGE_BE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE_BE}:latest

                        docker push ${DOCKER_IMAGE_FE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE_FE}:latest

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh """
                        ansible-playbook \
                        -i ansible/inventory.ini \
                        ansible/deploy-app.yml \
                        -e docker_image_be=${DOCKER_IMAGE_BE} \
                        -e docker_image_fe=${DOCKER_IMAGE_FE} \
                        -e docker_tag=${DOCKER_TAG}
                    """
                }
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    ansible appservers \
                    -i ansible/inventory.ini \
                    -m uri \
                    -a "url=http://localhost:8080/api/tasks/health status_code=200" \
                    --become
                '''
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }

        failure {
            echo 'Deployment failed. Check the Jenkins console log.'
        }
    }
}
