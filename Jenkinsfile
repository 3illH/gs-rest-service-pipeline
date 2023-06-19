// #!groovy
// @Library('pipeline-shared-lib@master') _

// def pipelineConfig = [buildNumber   : currentBuild.getNumber(),
//                       isMicro       : true,
//                       hasSwagger    : true,
//                       branchSwagger : "develop",
//                       steps         : "checkout,build,test,dockerBuild,trivy,dockerPush",
//                       projectName   : "gs-rest-service"]

// standardSharedLib(pipelineConfig)

def bitbucketUsername = 'smk-jenkins'
def bitbucketPassword = ''

pipeline {
    agent {
        label 'mavenjenkinsagent'
    }
    
    stages {
        stage('Setup Database Credentials') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'database-credentials', passwordVariable: 'DB_PASSWORD', usernameVariable: 'DB_USERNAME')]) {
                        //env.password = sh(returnStdout: true, script: 'echo $DB_PASSWORD').trim()
                        bitbucketPassword = env.DB_PASSWORD
                    }
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    withMaven(globalMavenSettingsConfig: '', jdk: 'OpenJDK 19', maven: 'Maven 3.3.9', mavenSettingsConfig: '', traceability: true) {
                        sh 'export'
                        sh 'java -version'
                        sh 'mvn -version'
                        sh "mvn -f --batch-mode release:prepare -Dusername=${bitbucketUsername} -Dpassword=${bitbucketPassword}"
                    }
                }
            }
        }
    }
}
