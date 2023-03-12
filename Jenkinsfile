@Library('piper-lib-os') _
  
node() {
       
abapEnvironmentCloneGitRepo (
  script: this,
  repositoryName: 'ZTST_PRODUCT',
  branchName: 'main',
  abapCredentialsId: 'CF_CREDENTIAL_EPAM',
  cfApiEndpoint: 'https://api.cf.eu10.hana.ondemand.com/',
  cfOrg: 'abapenv-tst-org',
  cfSpace: 'abap-dev',
  cfServiceInstance: 'abapenv1',
  cfServiceKeyName: 'key2'
)

}


