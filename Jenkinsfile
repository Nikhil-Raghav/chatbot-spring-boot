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
              sh """
               trivy fs . \
               --severity CRITICAL \
               --exit-code 1 \
               --format html \
               --output trivy-fs-report-${BUILD_NUMBER}.html
              """
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
             sh """
                trivy image ${IMAGE_NAME} \
                --severity CRITICAL \
                --exit-code 1 \
                --format html \
                --output trivy-image-report-${BUILD_NUMBER}.html
               """
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
 withKubeConfig(
    caCertificate: '',
    clusterName: '',
    contextName: 'DevOpsDiaries-cluster',
    credentialsId: 'kube',
    namespace: 'java-blogpost',
    restrictKubeConfigAccess: false,
    serverUrl: 'https://CF2E8DFB22453262703C0CBF06B9B4DA.gr7.us-west-2.eks.amazonaws.com'
) {
    sh "sed -i 's|replace|${IMAGE_NAME}|g' deployment.yml"
    sh "kubectl apply -f deployment.yml -n ${NAMESPACE}"
}

            }
        }

        stage('verify') {
    steps {
            withKubeConfig(
    caCertificate: '',
    clusterName: '',
    contextName: 'DevOpsDiaries-cluster',
    credentialsId: 'kube',
    namespace: 'java-blogpost',
    restrictKubeConfigAccess: false,
    serverUrl: 'https://CF2E8DFB22453262703C0CBF06B9B4DA.gr7.us-west-2.eks.amazonaws.com'
) {
} {
            sh '''
                kubectl get pods -n ${NAMESPACE}
                kubectl get svc  -n ${NAMESPACE}
            '''
        }
    }
}
    }
    post {
    always {
        archiveArtifacts artifacts: 'trivy-*.html', fingerprint: true
    }
}
}
