@Library('piper-lib-os') _
  
node() {
       
abapEnvironmentPullGitRepo (
  script: this,
  repositoryName: 'ZTEST',
  abapCredentialsId: 'CF_CREDENTIAL_EPAM',
  cfApiEndpoint: 'https://api.cf.eu10.hana.ondemand.com/',
  cfOrg: 'abapenv-tst-org',
  cfSpace: 'abap-dev',
  cfServiceInstance: 'abapenv-tst-inst',
  cfServiceKeyName: 'key2'
)

}


