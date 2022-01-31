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
        container('kubectl'){
          // withKubeConfig ([credentialsId: 'minikube-kubeconfig']) {

          //   // sh "kubectl apply -f ./argo/argo-application.yaml -n argocd"
          // }
          withCredentials([usernamePassword(credentialsId: 'argocd', passwordVariable: 'argopassword', usernameVariable: 'argousername')]) {
            sh "curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
            sh "chmod +x /usr/local/bin/argocd"
            sh "argocd login 10.100.148.208 --insecure --username=$argousername --password=$argopassword"
          }
        }
      }
    }
  }
}