pipeline {
  agent {
    kubernetes {
      yaml 'build-pod.yaml'
    }

  }
  stages {
    stage('Checkout SMC') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: 'main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/3illH/gs-rest-service-pipeline']]])
      }
    }
    stage('Build') {
      steps {
        container('maven') {
          script {
            sh "mvn clean package -DskipTests"
          }
        }
      }
    }
    stage('Trivy Scan Docker image') {
      steps {
        container('trivy') {
          script {
            sh "trivy image maven:alpine"
          }
        }
      }
    }
  }
}