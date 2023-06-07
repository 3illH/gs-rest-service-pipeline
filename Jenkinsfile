// #!groovy
// @Library('pipeline-shared-lib@master') _

// def pipelineConfig = [buildNumber   : currentBuild.getNumber(),
//                       isMicro       : true,
//                       hasSwagger    : true,
//                       branchSwagger : "develop",
//                       steps         : "checkout,build,test,dockerBuild,trivy,dockerPush",
//                       projectName   : "gs-rest-service"]

// standardSharedLib(pipelineConfig)

pipeline {
    agent {
        label 'mavenjenkinsagent'
    }
    
    stages {
        stage('Build') {
            steps {
                script {
                    withMaven(globalMavenSettingsConfig: '', jdk: 'OpenJDK 19', maven: 'Maven 3.3.9', mavenSettingsConfig: '', traceability: true) {
                        sh 'export'
                        sh 'java -version'
                        sh 'mvn -version'
                    }
                }
            }
        }
    }
}
