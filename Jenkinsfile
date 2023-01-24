#!groovy
@Library('pipeline-shared-lib@master') _

def pipelineConfig = [buildNumber   : currentBuild.getNumber(),
                      isMicro       : true,
                      hasSwagger    : true,
                      branchSwagger : "develop",
                      steps         : "checkout,build,test,dockerBuild,trivy,dockerPush",
                      projectName   : "gs-rest-service"]

standardSharedLib(pipelineConfig)