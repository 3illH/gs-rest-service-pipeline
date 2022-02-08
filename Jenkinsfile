pipeline {
  agent {
    kubernetes {
      yamlFile 'build-pod.yaml'
    }

  }
  environment {
    MAVEN_OPTS = "-Dmaven.repo.local=/m2"
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
            dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
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
            sh "argocd app create -f ./argo/argo-application.yaml --kustomize-image 3ill/gs-rest-service --upsert"
            sh "argocd app sync gs-rest-service --force"
            sh "argocd app wait gs-rest-service --timeout 600"
          }
        }
      }
    }
   }
  post {
    always {
      recordIssues enabledForFailure: true, tool: trivy(pattern: 'trivy-results.json')
      //recordIssues enabledForFailure: true, tool: owaspDependencyCheck(pattern: 'target/dependency-check-report.json')
    }
  }
}