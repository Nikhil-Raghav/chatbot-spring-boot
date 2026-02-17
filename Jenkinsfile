pipeline {
    agent any // decides which node to run

    tools {
        jdk 'java-17'
        maven 'maven'
    }

    environment {
        IMAGE_NAME   = "nikhil-raghav/itkannadigaru-blogpost:${GIT_COMMIT}"
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

       // stage('Test Docker Image') {
    //steps {
      //  sh '''
        //    docker rm -f blogpost-container || true
          //  docker run -d --name blogpost-container -p 9001:8501 ${IMAGE_NAME}
       // '''
   // }
//}


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
               withKubeConfig
               (caCertificate: '', 
               clusterName: ' DevOpsDiaries-cluster', 
               contextName: '', 
               credentialsId: '', 
               namespace: 'java-blogpost', 
               restrictKubeConfigAccess: false, 
               serverUrl: 'https://467324461E788FAAF1B9A0571F09DCC5.gr7.us-west-2.eks.amazonaws.com') {
} {
                    sh '''
                        sed -i "s|replace|${IMAGE_NAME}|g" deployment.yml
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
                    namespace: 'java-blogpost',
                    restrictKubeConfigAccess: false,
                    serverUrl: 'https://440D50D3C5AFE956D6AE5085DDF14988.gr7.us-west-2.eks.amazonaws.com'
                ) {
                    sh '''
                        kubectl get pods -n ${NAMESPACE}
                        kubectl get svc  -n ${NAMESPACE}
                    '''
                }
            }
        }
    }
}
