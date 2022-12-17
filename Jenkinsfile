@Library('piper-lib-os') _

node() {
    
    stage('prepare') {
        checkout scm
        setupCommonPipelineEnvironment script:this
    }

    stage('prepare system') {
        abapEnvironmentCreateSystem script: this
    }
}
