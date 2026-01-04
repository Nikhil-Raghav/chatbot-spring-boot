pipeline {
    agent any // decides which node to run

    tools {
        jdk 'java-17'
        maven 'maven'
    }

    environment {
        IMAGE_NAME   = "manojkrishnappa/itkannadigaru-blogpost:${GIT_COMMIT}"
        AWS_REGION   = "us-west-2"
        CLUSTER_NAME = "itkannadigaru-cluster"
        NAMESPACE    = "microdegree"
    }

    stages {

        stage('git-checkout') {
            steps {
                git url: 'https://github.com/ManojKRISHNAPPA/ITKannadigaru-Java-based-app.git', branch: 'prod'
            }
        }

        stage('Compile') {
            steps {
                sh '''
                    mvn compile
                '''
            }
        }

        stage('packaging') {
            steps {
                sh '''
                    mvn clean package
                '''
            }
        }

        stage('docker-build') {
            steps {
                sh '''
                    printenv
                    docker build -t ${IMAGE_NAME} .
                '''
            }
        }

        stage('Docker-testing') {
            steps {
                sh '''
                    CONTAINER_NAME=itkannadigaru-blogpost-test

                    echo "Checking if container exists..."
                    if docker ps -a --format '{{.Names}}' | grep -w $CONTAINER_NAME > /dev/null; then
                        echo "Old container found. Stopping and removing..."
                        docker stop $CONTAINER_NAME || true
                        docker rm   $CONTAINER_NAME || true
                    fi

                    echo "Creating fresh container..."
                    docker run -it -d \
                      --name $CONTAINER_NAME \
                      -p 9000:8080 \
                      ${IMAGE_NAME}
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-hub-creds',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo $DOCKER_PASSWORD | docker login \
                        -u $DOCKER_USERNAME --password-stdin
                    '''
                }
            }
        }

        stage('Push to dockerhub') {
            steps {
                sh '''
                    docker push ${IMAGE_NAME}
                '''
            }
        }

        stage('update the k8 cluster') {
            steps {
                sh '''
                    aws eks update-kubeconfig \
                      --region ${AWS_REGION} \
                      --name ${CLUSTER_NAME}
                '''
            }
        }

        stage('Deploy to EKS cluster') {
            steps {
                withKubeConfig(
                    caCertificate: '',
                    clusterName: 'itkannadigaru-cluster',
                    contextName: '',
                    credentialsId: 'kube',
                    namespace: 'microdegree',
                    restrictKubeConfigAccess: false,
                    serverUrl: 'https://B5C5676A4A23F5E9424B27B485E2AD73.gr7.us-west-2.eks.amazonaws.com'
                ) {
                    sh '''
                        sed -i 's|replace|${IMAGE_NAME}|g' deployment.yml
                        kubectl apply -f deployment.yml -n ${NAMESPACE}
                    '''
                }
            }
        }

        stage('verify') {
            steps {
                withKubeConfig(
                    caCertificate: '',
                    clusterName: 'itkannadigaru-cluster',
                    contextName: '',
                    credentialsId: 'kube',
                    namespace: 'microdegree',
                    restrictKubeConfigAccess: false,
                    serverUrl: 'https://B5C5676A4A23F5E9424B27B485E2AD73.gr7.us-west-2.eks.amazonaws.com'
                ) {
                    sh '''
                        kubectl get pods -n microdegree
                        kubectl get svc  -n ${NAMESPACE}
                    '''
                }
            }
        }
    }
}
