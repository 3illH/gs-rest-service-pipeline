// #!groovy
// @Library('pipeline-shared-lib@master') _

// def pipelineConfig = [buildNumber   : currentBuild.getNumber(),
//                       isMicro       : true,
//                       hasSwagger    : true,
//                       branchSwagger : "develop",
//                       steps         : "checkout,build,test,dockerBuild,trivy,dockerPush",
//                       projectName   : "gs-rest-service"]

// standardSharedLib(pipelineConfig)

def bitbucketCredentials = 'database-credentials'

pipeline {
    agent any
    // {
    //     label 'mavenjenkinsagent'
    // }
    
    stages {
        stage('Check Branch Indexing') {
            steps {
                script {
                    // if ( currentBuild.getBuildCauses().toString().contains('BranchIndexingCause')) {
                        def currentBranch = env.BRANCH_NAME
                        def previousRuns = previousBuilds(currentBranch)
                        echo "previousRuns '${previousRuns}' "
                        
                        if (shouldDiscardRun(previousRuns)) {
                            catchError(buildResult: 'ABORTED', stageResult: 'ABORTED') {
                                echo "Discarding current run for branch '${currentBranch}' in BranchIndexing as a more older run exists"
                                sh "exit 1"
                            }
                            // echo "Discarding current run for branch '${currentBranch}' in BranchIndexing as a more older run exists"
                            // currentBuild.result = 'ABORTED'
                            // return
                        }
                    // }
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
                        withCredentials([usernamePassword(credentialsId: bitbucketCredentials, passwordVariable: 'DB_PASSWORD', usernameVariable: 'DB_USERNAME')]) {
                            //env.password = sh(returnStdout: true, script: 'echo $DB_PASSWORD').trim()
                            //bitbucketPassword = env.DB_PASSWORD
                            sh "mvn -f --batch-mode release:prepare -Dusername=${DB_USERNAME} -Dpassword=${DB_PASSWORD}"
                        }
                        
                    }
                }
            }
        }
    }
}
