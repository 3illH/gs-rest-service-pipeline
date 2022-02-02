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
            sh "mvn clean package -DskipTests -Dmaven.repo.local=/m2"
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
            sh "trivy image -f json -o trivy-results.json 3ill/gs-rest-service"
          }
        }
      }
    }
    stage('Deploy with ArgoCd') {
      steps {
        container('argocd'){
          withCredentials([usernamePassword(credentialsId: 'argocd', passwordVariable: 'argopassword', usernameVariable: 'argousername')]) {
            sh "argocd login 10.100.148.208 --insecure --username=$argousername --password=$argopassword"
            sh "argocd app create -f ./argo/argo-application.yaml"
          }
        }
      }
    }
  }
  post {
    always {
      recordIssues enabledForFailure: true, tool: trivy(pattern: 'trivy-results.json')
    }
  }
}