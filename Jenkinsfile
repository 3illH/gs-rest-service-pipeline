pipeline {
  agent {
    kubernetes {
      yamlFile 'build-pod.yaml'
    }

  }
  stages {
    stage('Checkout SMC') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: 'master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/3illH/gs-rest-service-pipeline']]])
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
          sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify --cache=true --destination=3ill/gs-rest-service --force' 
        }
      }
    }
    stage('Trivy Scan Container image') {
      steps {
        container('trivy') {
          script {
            sh "trivy image 3ill/gs-rest-service"
          }
        }
      }
    }
    stage('Deploy with ArgoCd') {
      steps {
        script {
          sh "kubectl apply -f ./argo/argo-application.yaml -n argocd"
        }
      }
    }
  }
}