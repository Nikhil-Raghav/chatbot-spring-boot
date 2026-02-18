pipeline {
    agent any

    tools {
        jdk 'java-17'
        maven 'maven'
    }

    environment {
        IMAGE_NAME   = "nikhilraghav08/itkannadigaru-blogpost:${GIT_COMMIT}"
        AWS_REGION   = "us-west-2"
        CLUSTER_NAME = "DevOpsDiaries-cluster"
        NAMESPACE    = "java-blogpost"
    }

    stages {

        stage('git-checkout') {
            steps {
                git url: 'https://github.com/Nikhil-Raghav/chatbot-spring-boot.git', branch: 'main'
            }
        }

        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }

        /* ---------- SonarQube ---------- */
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube-server') {
                    sh '''
                    mvn sonar:sonar \
                    -Dsonar.projectKey=chatbot-spring-boot \
                    -Dsonar.projectName=chatbot-spring-boot
                    '''
                }
            }
        }

        /* ---------- Quality Gate ---------- */
        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('packaging') {
            steps {
                sh 'mvn clean package'
            }
        }

        /* ---------- Trivy FS Scan ---------- */
        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs . --exit-code 0 --severity HIGH,CRITICAL"
            }
        }

        stage('docker-build') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME} .
                '''
            }
        }

        /* ---------- Trivy Image Scan ---------- */
        stage('Trivy Image Scan') {
            steps {
                sh "trivy image ${IMAGE_NAME} --exit-code 0 --severity HIGH,CRITICAL"
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
                sh 'docker push ${IMAGE_NAME}'
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

        stage('Deploy to EKS cluster'){
            steps{
               withKubeConfig(caCertificate: '', 
               clusterName: 'DevOpsDiaries-cluster', 
               contextName: '', 
               credentialsId: 'kube', 
               namespace: 'java-blogpost', 
               restrictKubeConfigAccess: false, 
               serverUrl: 'https://7D363F6AD9325B22C3BCB5CE2B999F97.gr7.us-west-2.eks.amazonaws.com') {
                    sh " sed -i 's|replace|${IMAGE_NAME}|g' deployment.yml "
                    sh " kubectl apply -f deployment.yml -n ${NAMESPACE}"
}
            }
        }

        stage('verify') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'DevOpsDiaries-cluster', contextName: '', credentialsId: 'kube', namespace: 'java-blogpost', restrictKubeConfigAccess: false, serverUrl: 'https://7D363F6AD9325B22C3BCB5CE2B999F97.gr7.us-west-2.eks.amazonaws.com') {
    // some block
}
                    sh '''
                        kubectl get pods -n ${NAMESPACE}
                        kubectl get svc  -n ${NAMESPACE}
                    '''
                }
            }
        }
    }
}
