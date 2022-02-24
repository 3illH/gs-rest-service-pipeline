def FAILED_STAGE
pipeline {
  agent {
    kubernetes {
      yamlFile 'build-pod.yaml'
    }

  }
  environment {
    MAVEN_OPTS = "-Dmaven.repo.local=/m2"
    DOCKERHUB_CREDENTIALS=credentials('dockerCredentials')
    ARGOCDIP=credentials('argocdip')
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
            pom = readMavenPom file: "pom.xml";
            sh "mvn clean package -DskipTests"
          }
        }
      }
    }
    // stage('Test') {
    //   steps {
    //     container('maven') {
    //       script {
    //         sh "mvn clean verify"
    //         dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
    //       }
    //     }
    //   }
    // }
    // stage('SonarQube Analysis') {
    //   steps {
    //     container('maven') {
    //       withSonarQubeEnv('Sonar') {
    //         sh "mvn clean verify sonar:sonar -Dsonar.projectKey=gs-rest-service"
    //       }
    //     }
    //   }
    // }
    stage('Build with Docker') {
      steps {
        container('docker') {
          script{
            dockerImageName = "3ill/gs-rest-service:${pom.version}"
            dockerImage = docker.build("${dockerImageName}", ".")
          }
        }
      }
    }
    
    // stage('Trivy Scan Container image') {
    //   steps {
    //     container('trivy') {
    //       script {
    //         FAILED_STAGE=env.STAGE_NAME
    //         sh "trivy image -f json -o trivy-results.json 3ill/gs-rest-service:0.0.2-SNAPSHOT"
    //       }
    //     }
    //   }
    // }
    stage('Push with Docker') {
      steps {
        container('docker') {
          script{
            sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            sh "docker push ${dockerImageName}"
          }
        }
      }
    }
    stage('Deploy with ArgoCd') {
      steps {
        container('argocd'){
          withCredentials([usernamePassword(credentialsId: 'argocd', passwordVariable: 'argopassword', usernameVariable: 'argousername')]) {
            // 10.100.148.208
            sh "argocd login $ARGOCDIP --insecure --username=$argousername --password=$argopassword"
            sh "argocd app set  gs-rest-service --kustomize-image ${dockerImageName}"
            sh "argocd app sync gs-rest-service --force --prune"
            sh "argocd app wait gs-rest-service --timeout 600"
          }
        }
      }
    }
   }
  // post {
  //   always {
  //     recordIssues enabledForFailure: true, tool: trivy(pattern: 'trivy-results.json')
  //     script{
  //       def total = tm stringWithMacro: '${ANALYSIS_ISSUES_COUNT, tool="trivy", type="TOTAL"}'
  //       def news = tm stringWithMacro: '${ANALYSIS_ISSUES_COUNT, tool="trivy", type="NEW"}'
  //       def totalHight = tm stringWithMacro: '${ANALYSIS_ISSUES_COUNT, tool="trivy", type="TOTAL_HIGH"}'
  //       def totalNormal = tm stringWithMacro: '${ANALYSIS_ISSUES_COUNT, tool="trivy", type="TOTAL_NORMAL"}'
  //       echo "TOTAL: " + total
  //       echo "NEWS: " + news
  //       echo "HIGH: " + totalHight
  //       echo "NORMAL: " + totalNormal
  //     }
  //     recordIssues enabledForFailure: true, tool: owaspDependencyCheck(pattern: 'target/dependency-check-report.json')
  //   }
  // }
}