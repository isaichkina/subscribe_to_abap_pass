#!/bin/bash

source ./func.sh

#========================MAIN SECTION============================

#Global variables
sGlobalPath="/path/to/current/folder"
sUserName=$1
sURL=$2
sSubDomain=$3
sPassword=$4
#---------------
cd $sGlobalPath
pwd

CheckParams $#
BTPLogin $sUserName $sURL $sSubDomain $sPassword
echo "$(date '+%d/%b/%Y %H:%M:%S') login success">&2

# =================Section for APP
#sAPPDistrEntitlements="DEFAULT,ENTITLEMENTS,AUTHORIZATIONS"
#sPathToDirEnt="ProdDirEntits.ent"
sPathToSAEnt=Abap.ent
#sAPPDirName="ClientLink"
sAPPDirAdmins="[\"dzmitry_gotta@epam.com\"]"
sAPPSAName=autoAbapEnv
sAPPSARegion=eu10
sAPPSASubDomainName=epamAbapDev
sAPPEnvType=cloudfoundry
sAPPEnvService=cloudfoundry
sAPPEnvPlan=standard
sAPPCFParams="{\"instance_name\":\""$sAPPSASubDomainName"_org\"}"
sAbapParams="{\"admin_email\": \"your-email@epam.com\", \"description\": \"Created by IaC\", \"is_development_allowed\": true, \"sapsystemname\": \"H01\", \"size_of_runtime\": 1,\"size_of_persistence\": 4}"
sAPPSpaceName=AbapDev

sAPPDirID=b4a3bd13-4a81-4ba4-bbb1-71a5d5bd78c0


#sAPPDirID=$(CreateDirectory $sSubDomain $sAPPDistrEntitlements $sAPPDirName $sAPPDirAdmins)
#echo "$(date '+%d/%b/%Y %H:%M:%S') Directory $sAPPDirName created with ID: $sAPPDirID">&2

#AssignDirEntitlements $sAPPDirID

sAPPSAID=$(CreateSubaccount $sAPPSAName $sAPPSARegion $sAPPSASubDomainName $sAPPDirAdmins $sAPPDirID)
if [ -z ${sAPPSAID} ]; then
    echo "*** ERROR 14 in function CreateSubaccount">&2
    exit 14
    ## Error 14 = Error creating subaccount
fi
echo "$(date '+%d/%b/%Y %H:%M:%S') Subaccount $sAPPSAName created with ID: $sAPPSAID">&2

# -------Entitlements were auto-assigned 
# AssignSAEntitlements $sAPPSAID

AssignRole $sAPPSAID "Subaccount Administrator" pavel_belski@epam.com
#AssignRole $sAPPSAID "Subaccount Viewer" karina_blagushko@epam.com

sAPPEnvID=$(CreateEnv $sAPPSAID $sAPPEnvType $sAPPEnvService $sAPPEnvPlan $sAPPCFParams $sAPPSASubDomainName)
if [ -z ${sAPPEnvID} ]; then
    echo "*** ERROR 16 in function CreateEnv">&2
    exit 16
    ## Error 16 = Error creating environment
fi
echo "$(date '+%d/%b/%Y %H:%M:%S') Environment with type $sAPPEnvType created with ID: $sAPPEnvID">&2

LoginCF $sUserName $sAPPSARegion $sAPPSASubDomainName $sPassword

CreateSpace $sAPPSpaceName $sAPPSASubDomainName

CreateService $sAPPSpaceName 'destination' 'lite' 'AbapDestSrv'
CreateSubscription $sAPPSAID 'abapcp-web-router' 'default'
CreateService $sAPPSpaceName 'abap' 'standard' 'AbapEnvSrv' $sAbapParams

echo $(date '+%d/%b/%Y %H:%M:%S')" END OF SCRIPT">&2
exit
