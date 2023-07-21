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
    {
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

def previousBuilds(branch) {
    // Get all previous builds for the current job and the given branch
    return Jenkins.instance.getItemByFullName(env.JOB_NAME).getBuilds().findAll { build ->
        build.environment['BRANCH_NAME'] == branch
    }
}

def shouldDiscardRun(previousRuns) {
    // Check if there is a more recent run for the branch
    return previousRuns.any { it.number < currentBuild.number }
}

def abortCurrentBuild() {
    print "INFO: Build skipped due to trigger being Branch Indexing"
    currentBuild.result = 'ABORTED'
    return
}
