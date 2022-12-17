#!/bin/bash

#function CheckParams checks number of parameters
function CheckParams {
    if [ $1 -le 2 ]; then
	echo "*** ERROR 11">&2
#	echo "    Usage: MainScript.sh \"UserName\" \"Password\" \"URL\" \"SubDomain\"">&2
	echo "    Usage: MainScript.sh \"UserName\" \"URL\" \"SubDomain\"">&2
	exit 11
	## Error 11 = not enogh parameters
fi
}

#function BTPLogin UserName Password URL SubDomain
function BTPLogin {
    if [ $# -le 2 ]; then
	echo "*** ERROR 11 in function BTPLogin">&2
#	echo "    Usage: BTPLogin \"UserName\" \"Password\" \"URL\" \"SubDomain\"">&2
	echo "    Usage: BTPLogin \"UserName\" \"URL\" \"SubDomain\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    #echo "Enter password for user $1"
    local sR=`btp login --url $2 --subdomain $3 --user $1 --password $4 2>&1`
    #echo "-"$4"-"
#    local sR=`btp login --url $2 --subdomain $3 --sso 2>&1`
    if [[ $sR != *"Login successful"* ]]; then
	echo "*** ERROR 12 in function BTPLogin">&2
	echo "$sR">&2
	exit 12
	## Error 12 = invalid login
    fi
}

#function IsDirExists SubDomain DirDisplayName
function IsDirExists {
    if [ $# -le 1 ]; then
	echo "*** ERROR 11 in function IsDirExists">&2
	echo "    Usage: IsDirExists \"SubDomain\" \"DisplayName\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    local sR=`btp get accounts/global-account --global-account $1 --show-hierarchy 2>&1`
    local sFlag=`echo "$sR" | grep "directory " | grep $2`
    if [[ "$sFlag" == *"$2"* ]]; then
	echo "*** ERROR 13">&2
	echo "    Directory with name $2 exists. See ID:(`echo "$sFlag" | awk '{ print $2 }'`).">&2
	exit 13
	## Error 13 = directory exists
    fi
}

#function IsDirCreated DirID
function IsDirCreated {
#echo $#
#echo $@
    if [ $# -eq 0 ] || [ $# -gt 1 ]; then
	echo "*** ERROR 11 in function IsDirCreated">&2
	echo "    Usage: IsDirCreated \"DirID\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    local sF=0
    while [ $sF != 1 ]
    do
	local sL=`btp get accounts/directory $1 2>&1`
	if [[ "$sL" == *"Directory created."* ]]; then
	    local sF=1
	fi
	sleep 5 
    done
}

#function CreateDirectory SubDomain Features DirDisplayName DirectoryAdmins
function CreateDirectory {
#echo $#
#echo $@
    if [ $# -le 3 ]; then
	echo "*** ERROR 11 in function CreateDirectory">&2
	echo "    Usage: CreateDirectory \"SubDomain\" \"Features\" \"DisplayName\" \"DirectoryAdmins\"">&2
	echo "           Features: DEFAULT,ENTITLEMENTS,AUTHORIZATIONS">&2
	echo "           DirectoryAdmins: [\\\"user1@mail.com\\\",\\\"user2@mail.com\\\"]">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    echo "$(date '+%d/%b/%Y %H:%M:%S') Check if directory $3 already exists ">&2
    IsDirExists $1 $3
    echo "$(date '+%d/%b/%Y %H:%M:%S') Creating directory $3">&2
    local sR=`btp create accounts/directory --global-account $1 --features $2 --display-name $3 --directory-admins $4 2>&1`
    local sDirID=`echo "$sR" | grep "directory id" | awk '{ print $3 }'`
    echo "$(date '+%d/%b/%Y %H:%M:%S') Waiting for creating directory $3 with ID $sDirID">&2
    IsDirCreated $sDirID
    echo $sDirID 
}

#function IsSubaccountExists SubDomain SubaccountName
function IsSubaccountExists {
    if [ $# -le 1 ]; then
	echo "*** ERROR 11 in function IsSubaccountExists">&2
	echo "    Usage: IsSubaccountExists \"SubDomain\" \"SubaccountName\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    local sR=`btp get accounts/global-account --global-account $1 --show-hierarchy 2>&1`
    local sFlag=`echo "$sR" | grep "subaccount " | grep $2`
    if [[ "$sFlag" == *"$2"* ]]; then
	echo "*** ERROR 13">&2
	echo "    Subaccount with name $2 exists. See ID:(`echo "$sFlag" | awk '{ print $2 }'`).">&2
	exit 13
	## Error 13 = directory exists
    fi
}

#function IsSubaccountCreated SAID
function IsSubaccountCreated {
#echo $#
#echo $@
    if [ $# -eq 0 ] || [ $# -gt 1 ]; then
	echo "*** ERROR 11 in function IsSubaccountCreated">&2
	echo "    Usage: IsSubaccountCreated \"SAID\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    local sF=0
    while [ $sF != 1 ]
    do
	local sL=`btp get accounts/subaccount $1 2>&1`
	if [[ "$sL" == *"Subaccount created."* ]]; then
	    local sF=1
	fi
	sleep 5 
    done
}

#function CreateSubaccount DisplayName Region SubDomainName AdminUsers [DirectoryID]
function CreateSubaccount {
    if [ $# -le 3 ]; then
	echo "*** ERROR 11 in function CreateSubaccount">&2
	echo "    Usage: CreateSubaccount \"DisplayName\" \"Region\" \"SubDomainName\" \"AdminUsers\" [\"DirectoryID\"]">&2
	echo "           AdminUsers: [\\\"user1@mail.com\\\",\\\"user2@mail.com\\\"]">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    echo "$(date '+%d/%b/%Y %H:%M:%S') Check if subaccount $1 already exists ">&2
    IsSubaccountExists $sSubDomain $1
    echo "$(date '+%d/%b/%Y %H:%M:%S') Creating subaccount $1">&2
    if [ $# -eq 5 ]; then
        local sR=`btp create accounts/subaccount --display-name $1 --region $2 --subdomain $3 --subaccount-admins $4 --directory $5 2>&1`
    else
	local sR=`btp create accounts/subaccount --display-name $1 --region $2 --subdomain $3 --subaccount-admins $4 2>&1`
    fi
    local sSAID=`echo "$sR" | grep "subaccount id" | awk '{ print $3 }'`
    if [[ "$sR" == *"Error"* ]]; then
	echo "*** ERROR 14 in function CreateSubaccount">&2
	echo "$sR">&2
	exit 14
	## Error 14 = Error creating subaccount
    fi
    echo "$(date '+%d/%b/%Y %H:%M:%S') Waiting for creating subaccount $1 with ID $sSAID">&2
    IsSubaccountCreated $sSAID
    echo $sSAID 

}

#function IsDirEntitlementAssigned DirID Service Plan
function IsDirEntitlementAssigned {
    if [ $# -le 2 ]; then
	echo "*** ERROR 11 in function IsDirEntitlementAssigned">&2
	echo "    Usage: IsDirEntitlementAssigned \"DirID\" \"Service\" \"Plan\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    local sF=0
    while [ $sF != 1 ]
    do
	local sL=`btp list accounts/entitlement --directory $1 2>&1`
	local sLL=`echo "$sL" | grep $2 | grep $3`
	if [ ${#sR} > 0 ];then
	    echo "$(date '+%d/%b/%Y %H:%M:%S') Service: [ $2 ]   Plan: [ $3 ] - ASSIGNED">&2
	    local sF=1
	fi
	sleep 5 
    done
}

#function AssignDirEntitlements DirID
function AssignDirEntitlements {
    if [ $# -eq 0 ] || [ $# -gt 1 ]; then
	echo "*** ERROR 11 in function AssignDirEntitlements">&2
	echo "    Usage: AssignDirEntitlements \"DirID\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    while read -r sLine
    do
	if [ "${sLine:0:1}" != "#" ];then
	local iCnt=`echo "$sLine" | awk '{ print NF }'`
	    case "$iCnt" in
		"2")
		    local sService=`echo "$sLine" | awk '{print $1 }'`
		    local sPlan=`echo "$sLine" | awk '{print $2 }'`
		    local sOut=`btp assign accounts/entitlement --to-directory $1 --for-service $sService --plan $sPlan --distribute --auto-assign --enable 2>&1`
#		    echo "Service:$sService Plan:$sPlan"
#		    echo "$sOut"
		;;
#		"3")
#		   local sService=`echo "$sLine" | awk '{print $1 }'`
#		    local sPlan=`echo "$sLine" | awk '{print $2 }'`
#		    local sAmount=`echo "$sLine" | awk '{print $3 }'`
#		    echo "Service:$sService Plan:$sPlan Amount:$sAmount"
#		;;
		"4")
		    local sService=`echo "$sLine" | awk '{print $1 }'`
		    local sPlan=`echo "$sLine" | awk '{print $2 }'`
		    local sAmount=`echo "$sLine" | awk '{print $3 }'`
		    local sAAmount=`echo "$sLine" | awk '{print $4 }'`
		    local sOut=`btp assign accounts/entitlement --to-directory $1 --for-service $sService --plan $sPlan --amount $sAmount --auto-distribute-amount $sAAmount --distribute --auto-assign 2>&1`
#		    echo "Service:$sService Plan:$sPlan Amount:$sAmount AAmount:$sAAmount"
#		    echo "$sOut"
		;;
	    esac
	    if [[ "$sOut" == *"Error"* ]]; then
		echo "*** ERROR 15 in function AssignDirEntitlements">&2
		echo "$sOut">&2
		exit 15
		## Error 15 = Assign entitlement error
	    fi
	    IsDirEntitlementAssigned $1 $sService $sPlan
	fi
    done<$sPathToDirEnt
}

#function IsSAEntitlementAssigned SAID Service Plan
function IsSAEntitlementAssigned {
    if [ $# -le 2 ]; then
	echo "*** ERROR 11 in function IsSAEntitlementAssigned">&2
	echo "    Usage: IsSAEntitlementAssigned \"SAID\" \"Service\" \"Plan\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    local sF=0
    while [ $sF != 1 ]
    do
	local sL=`btp list accounts/entitlement --subaccount $1 2>&1`
	local sLL=`echo "$sL" | grep $2 | grep $3`
	if [ ${#sR} > 0 ];then
	    echo "$(date '+%d/%b/%Y %H:%M:%S') Service: [ $2 ]   Plan: [ $3 ] - ASSIGNED">&2
	    local sF=1
	fi
	sleep 5 
    done
}

#function AssignSAEntitlements SAID
function AssignSAEntitlements {
    if [ $# -eq 0 ] || [ $# -gt 1 ]; then
	echo "*** ERROR 11 in function AssignSAEntitlements">&2
	echo "    Usage: AssignSAEntitlements \"SAID\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    while read -r sLine
    do
	if [ "${sLine:0:1}" != "#" ];then
	local iCnt=`echo "$sLine" | awk '{ print NF }'`
	    case "$iCnt" in
		"2")
		    local sService=`echo "$sLine" | awk '{print $1 }'`
		    local sPlan=`echo "$sLine" | awk '{print $2 }'`
		    local sOut=`btp assign accounts/entitlement --to-subaccount $1 --for-service $sService --plan $sPlan --enable 2>&1`
		    echo "Service:$sService Plan:$sPlan"
		    echo "$sOut"
		;;
#		"3")
#		   local sService=`echo "$sLine" | awk '{print $1 }'`
#		    local sPlan=`echo "$sLine" | awk '{print $2 }'`
#		    local sAmount=`echo "$sLine" | awk '{print $3 }'`
#		    echo "Service:$sService Plan:$sPlan Amount:$sAmount"
#		;;
		"3")
		    local sService=`echo "$sLine" | awk '{print $1 }'`
		    local sPlan=`echo "$sLine" | awk '{print $2 }'`
		    local sAmount=`echo "$sLine" | awk '{print $3 }'`
		    local sAAmount=`echo "$sLine" | awk '{print $4 }'`
		    local sOut=`btp assign accounts/entitlement --to-subaccount $1 --for-service $sService --plan $sPlan --amount $sAmount 2>&1`
		    echo "Service:$sService Plan:$sPlan Amount:$sAmount AAmount:$sAAmount"
		    echo "$sOut"
		;;
	    esac
	    if [[ "$sOut" == *"Error"* ]] | [[ "$sOut" == *"FAILED"* ]]; then
		echo "*** ERROR 15 in function AssignSAEntitlements">&2
		echo "$sOut">&2
		exit 15
		## Error 15 = Assign entitlement error
	    fi
	    IsSAEntitlementAssigned $1 $sService $sPlan
	fi
    done<$sPathToSAEnt
}

#function IsEnvCreated EnvID SAID
function IsEnvCreated {
#echo $#
#echo $@
    if [ $# -le 1 ]; then
	echo "*** ERROR 11 in function IsEnvCreated">&2
	echo "    Usage: IsEnvCreated \"EnvID\" \"SAID\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    local sF=0
    while [ $sF != 1 ]
    do
	local sL=`btp get accounts/environment-instance $1 --subaccount $2 2>&1`
	if [[ "$sL" == *"Environment instance created."* ]]; then
	    local sF=1
	fi
	sleep 5 
    done
}

#function IsEnvExists SAID EnvType EnvName
function IsEnvExists {
#    echo "$# - $@">&2
    if [ $# -le 2 ]; then
	echo "*** ERROR 11 in function IsEnvExists">&2
	echo "    Usage: IsSubaccountExists \"SAID\" \"EnvType\" \"EnvName\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    local sR=`btp list accounts/environment-instance --subaccount $1 2>&1`
    local sFlag=`echo "$sR" | grep $2 | grep $3"_"$2`
    if [[ "$sFlag" == *"$3"* ]]; then
	echo "*** ERROR 13">&2
	echo "    Environment with name "$3"_"$2" exists. See ID:(`echo "$sFlag" | awk '{ print $2 }'`).">&2
	exit 13
	## Error 13 = environment exists
    fi
}

#function CreateEnv SAID EnvType EnvService EnvPlan EnvParams SASubDomainName
function CreateEnv {
#echo "$@">&2
    if [ $# -le 5 ]; then
	echo "*** ERROR 11 in function CreateEnv">&2
	echo "    Usage: CreateEnv \"SAID\" \"EnvType\" \"EnvService\" \"EnvPlan\" \"EnvParams\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    echo "$(date '+%d/%b/%Y %H:%M:%S') Check if Environment $3 already exists ">&2
    IsEnvExists $1 $2 $6
    echo "$(date '+%d/%b/%Y %H:%M:%S') Creating environment $2">&2
    local sR=`btp create accounts/environment-instance --subaccount $1 --environment $2 --service $3 --plan $4 --parameters $5 2>&1`
    if [[ "$sR" == *"Error"* ]]; then
	echo "*** ERROR 16 in function CreateEnv">&2
	echo "$sR">&2
	exit 16
	## Error 16 = Create environment error
	    fi
    local sEnvID=`echo "$sR" | grep "environment id" | awk '{ print $3 }'`
    echo "$(date '+%d/%b/%Y %H:%M:%S') Waiting for creating environment $2 with ID $sEnvID">&2
    IsEnvCreated $sEnvID $1
    echo $sEnvID 
}

#function LoginCF UserName Region SASubDomainName
function LoginCF {
    if [ $# -le 2 ]; then
	echo "*** ERROR 11 in function LoginCF">&2
	echo "    Usage: LoginCF \"UserName\" \"Region\" \"SASubDomainName\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    #echo "-$1-$2-$3- Enter password for user $1"
    local sO=`cf7 login -u $1 -p $4 -o $3_org -a https://api.cf.$2.hana.ondemand.com 2>&1`
    echo " "
    if [[ "$sO" == *"FAILED"* ]] && [[ "$sO" != *"Select a space:"* ]];then
	echo "*** ERROR 17 in function LoginCF">&2
	echo "$sO">&2
	exit 17
	# Error 17 = failed Cloud foundry login
    fi
}

#function CreateSpace SpaceName SASubDomainName
function CreateSpace {
    if [ $# -le 1 ]; then
	echo "*** ERROR 11 in function CreateSpace">&2
	echo "    Usage: CreateSpace \"SpaceName\" \"SASubDomainName\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
echo "$(date '+%d/%b/%Y %H:%M:%S') Check if space $1 exists">&2
    local sO=`cf7 create-space $1 -o $2_org 2>&1`
    if [[ "$sO" == *"already exists."* ]];then
	echo "***ERROR 13 in function CreateSpace">&2
	echo "$sO">&2
	exit 13
	# Error 13 = space already exists
    fi
echo "$(date '+%d/%b/%Y %H:%M:%S') Done">&2
echo "$(date '+%d/%b/%Y %H:%M:%S') Check if error creating space $1">&2
    if [[ "$sO" == *"FAILED"* ]];then
	echo "***ERROR 18 in function CreateSpace">&2
	echo "$sO">&2
	exit 18
	# Error 18 = create space error
    fi
echo "$(date '+%d/%b/%Y %H:%M:%S') Done">&2
echo "$(date '+%d/%b/%Y %H:%M:%S') Check if can target space">&2
    if [[ "$sO" == *"TIP: Use "* ]];then
	local sT=`cf target -o $2_org -s $1 2>&1`
	if [[ "$sT" == *"FAILED"* ]];then
	    echo "***ERROR 19 in function CreateSpace">&2
	    echo "$sT">&2
	    exit 19
	    # Error 19 = target space error
	fi
    fi
echo "$(date '+%d/%b/%Y %H:%M:%S') Done">&2
}

#function CreateService SpaceName Service Plan ServiceInstance ServiceParams
function CreateService {
    echo "1-$1- 2-$2- 3-$3- 4-$4- 5=$5="
    echo $#
    iCP=$#
    if [ $iCP -lt 4 ]; then
	echo "*** ERROR 11 in function CreateService">&2
	echo "    Usage: CreateSpace \"SpaceName\" \"Service\" \"Plan\" \"ServiceInstance\" \"ServiceParams\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    
    echo "$(date '+%d/%b/%Y %H:%M:%S') Set target to $1">&2
    local sTarget=`cf7 target -s $1 2>&1`
    if [[ "$sTarget" == *"FAILED"* ]];then
	echo "***ERROR 19 in function CreateService">&2
	echo "$sTarget">&2
	exit 19
	# Error 19 = target space error
    fi
    echo "$(date '+%d/%b/%Y %H:%M:%S') Create service $4 in space $1">&2
    echo "number of params: $iCP"
    case "$iCP" in
		"4")
		    echo "4 params"
		    local sCR=`cf7 create-service $2 $3 $4 2>&1`
		;;
		"5")
		    echo "5 params"
		    local sCR=`cf7 create-service $2 $3 $4 -c $5 2>&1`
		;;
	    esac

    echo "------------------"
    echo $sCR
    echo "------------------"

    if [[ "$sCR" == *"Incorrect Usage:"* ]];then
	echo "***ERROR 20 in function CreateService">&2
	echo "$sCR">&2
	exit 20
	# Error 20 = create service error
    fi
    if [[ "$sCR" == *" already exists"* ]];then
	echo "***ERROR 13 in function CreateService">&2
	echo "$sCR">&2
	exit 13
	# Error 13 = service already exists
    fi
    echo "$(date '+%d/%b/%Y %H:%M:%S') Wait till service has been created">&2
    local sF=0
    while [ $sF != 1 ]
    do
	local sL=`cf7 service $4 2>&1`
	if [[ "$sL" == *"create succeeded"* ]]; then
	    local sF=1
	fi
	sleep 5 
    done
    echo "$(date '+%d/%b/%Y %H:%M:%S') Service $4 in space $1 created successfully">&2
}

#function CreateSubscription SAID SubAppName SubPlan
function CreateSubscription {
    if [ $# -le 2 ]; then
	echo "*** ERROR 11 in function CreateSubscription">&2
	echo "    Usage: CreateSubscription \"SAID\" \"SubAppName\" \"SubPlan\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    echo "$(date '+%d/%b/%Y %H:%M:%S') Chech if \"$2\" already subscripted">&2
    local sCSfull=`btp list accounts/subscription --subaccount $1 2>&1`
    local sCS=`echo "$sCSfull" | grep $2`
    if [[ "$sCS" == *"NOT_SUBSCRIBED"* ]];then
	local sOu=`btp subscribe accounts/subaccount --subaccount $1 --to-app $2 --plan $3 2>&1`
	if [[ "$sOu" == *"Command runs in the background."* ]];then
	    echo "$(date '+%d/%b/%Y %H:%M:%S') Wait till subscription \"$2\" has been created">&2
	    local sF=0
	    while [ $sF != 1 ]
	    do
		local sLfull=`btp list accounts/subscription --subaccount $1 2>&1`
		local sL=`echo "$sLfull" | grep $2`
		if [[ "$sL" == *" SUBSCRIBED "* ]]; then
		    local sF=1
		fi
	    sleep 5 
	    done
	    echo "$(date '+%d/%b/%Y %H:%M:%S') Subscription to app $2 created successfully">&2
	else
	    echo "***ERROR 21 in function CreateSubscription">&2
	    echo "$sOu">&2
	    exit 21
	    # Error 21 = create subscription error
	fi
    else
	echo "***ERROR 13 in function CreateSubscription">&2
	echo "$sTarget">&2
	exit 19
	# Error 19 = subscription already exists
    fi
}

#function AssignRole SAID RoleName toUser
function AssignRole {
    if [ $# -le 2 ]; then
	echo "*** ERROR 11 in function AssignRole">&2
	echo "    Usage: AssignRole \"SAID\" \"RoleName\" \"toUser\"">&2
	exit 11
	## Error 11 = not enogh parameters
    fi
    local sAR=`btp assign security/role-collection "$2" --to-user $3 --subaccount $1 --create-user-if-missing 2>&1`
    if [[ "$sAR" != *"OK"* ]];then
	echo "***ERROR 22 in function AssignRole">&2
	echo "$sAR">&2
	exit 13
	# Error 22 = assign role error
    fi
    echo "$(date '+%d/%b/%Y %H:%M:%S') Role \"$2\" assigned to user $3">&2
}
echo "functions are loaded">&2
