pipeline {
  agent {
    kubernetes {
      yamlFile 'build-pod.yaml'
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
    stage('Test') {
      steps {
        container('maven') {
          script {
            sh "mvn clean verify"
          }
        }
      }
    }
    stage('Build with Kaniko') {
      steps {
        container('kaniko') {
          sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify --cache=true --destination=gs-rest-service --force' 
        }
      }
    }
    // stage('Trivy Scan Docker image') {
    //   steps {
    //     container('trivy') {
    //       script {
    //         sh "trivy image maven:alpine"
    //       }
    //     }
    //   }
    // }
  }
}