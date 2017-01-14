#!/bin/bash
# ---------------------------------------------------
#
# version : 1.0.0
#
# Author: AF
#
# by Net2Action 
#
# ---------------------------------------------------
now=$(date)
PROGNAME=$(basename $0)
AUTHOR="A.Fontana"
VERSION="1.0.0"
OWNER="(c) by Net2Action  - 2016"


if [ -z "$logFile" ]; then
   mkdir -p ../log
   log=../log/$(echo $PROGNAME | cut -d "." -f 1)
   logFile=$log.log
fi


function error_noExit
{
        echo "[$now] ${PROGNAME} ${1}" >> ${logFile}
}

function error_exit
{
        echo "${PROGNAME}:[$LINENO] ${1}"
        echo "[$now] ${PROGNAME}:[$LINENO] ${1}" >> ${logFile}
        msgLine "---------------------------------------"
        echo "BUILD FAIL"
        exit 1
}

function msgLine
{
        echo "${PROGNAME}:[$LINENO] ${1}" 1>&2
        echo "[$now] ${PROGNAME}:[$LINENO] ${1}" >> ${logFile}
}

function checkGroupId
{
    groupName=$(grep "$groupId" /etc/group|cut -d: -f1)
     until [ "$groupName" == "" ]; do
        if [ "$groupName" != "" ] ; then
           groupId=$((groupId+10))
  	fi
        groupName=$(grep "$groupId" /etc/group|cut -d: -f1)
    done    	
}

function checkUserId
{
    userName=$(grep "$userId" /etc/passwd|cut -d: -f1)
     until [ "$userName" == "" ]; do
        if [ "$userName" != "" ] ; then
           userId=$((userId+10))
  	fi
        userName=$(grep "$userId" /etc/passwd|cut -d: -f1)
    done    	
}



function usage
{
  echo "*----------------------------------------------------------------------------------"
  echo "| ${OWNER}"
  echo "| Author : ${AUTHOR}"
  echo "| Program : ${PROGNAME} ${VERSION}"
  echo "| ========================== "
  echo "| ${PROGNAME}  [-i instance] [-h home] -p password"
  echo "|"
  echo "| instance name : eg. db2inst1 defualt db2inst1"
 echo "| home path :      home path of instance usually is /opt/data default is /opt/data"
  echo "| password:       password of Instance owner * Mandatory"
  echo "|"
  echo "*----------------------------------------------------------------------------------"
}

msgLine "Create USers and Groups begin at $(date)"

# Parse the command-line arguments
while [ "$#" -gt "0" ]; do
  case "$1" in
    -i)
      db2Instance="$2"
      shift 2
    ;;
    -h)
      db2Home="$2"
      shift 2
    ;;
    -p)
      db2Pwd="$2"
      shift 2
    ;;    
    -?|--help)
      usage
    exit 0
    ;;
    *)
      break
    ;;
  esac
done

if [ "$db2Instance" == "" ] ; then
 db2Instance="db2inst1"
fi
if [ "$db2Home" == "" ] ; then
 db2Home="/opt/data"
fi

if [ "$db2Pwd" == "" ] ; then
 error_exit "[$LINENO]: Missing, Db2 owner password, -p flag is mandatory"
fi

groupId=700
checkGroupId
returnMsg=$(groupadd -g $groupId db2iadm1 2>&1 1>/dev/null )
rc=$?
if [ ${rc} -ne 0 ] ; then
        echo "${returnMsg}" 
        error_noExit "[$LINENO]: ${returnMsg}"
fi
msgLine "Group Id : $groupId assigned to group: db2iadm1"
checkGroupId
returnMsg=$(groupadd -g $groupId db2fsdm1 2>&1 1>/dev/null )
rc=$?
if [ ${rc} -ne 0 ] ; then
        echo "${returnMsg}" 
        error_noExit "[$LINENO]: ${returnMsg}"
fi
msgLine "Group Id : $groupId assigned to group: db2fsdm1"
checkGroupId
returnMsg=$(groupadd -g $groupId dasadm1 2>&1 1>/dev/null )
rc=$?
if [ ${rc} -ne 0 ] ; then
        echo "${returnMsg}" 
        error_noExit "[$LINENO]: ${returnMsg}"
fi
msgLine "Group Id : $groupId assigned to group: dasadm1"

userId=1004
checkUserId
mkdir -p $db2Home
returnMsg=$(useradd -u $userId -g db2iadm1 -m -d $db2Home/$db2Instance $db2Instance 2>&1 1>/dev/null )
rc=$?
if [ ${rc} -ne 0 ] ; then
        echo "${returnMsg}" 
        error_noExit "[$LINENO]: ${returnMsg}"
fi
msgLine "User Id : $userId assigned to user: $db2Instance"
userId=$((userId+1))
checkUserId
returnMsg=$(useradd -u $userId -g db2fsdm1 -m -d /home/db2fenc1 db2fenc1 2>&1 1>/dev/null )
rc=$?
if [ ${rc} -ne 0 ] ; then
        echo "${returnMsg}" 
        error_noExit "[$LINENO]: ${returnMsg}"
fi
msgLine "User Id : $userId assigned to user: db2fenc1"
userId=$((userId+1))
checkUserId
returnMsg=$(useradd -u $userId -g dasadm1 -m -d /home/dasusr1 dasusr1 2>&1 1>/dev/null )
rc=$?
if [ ${rc} -ne 0 ] ; then
        echo "${returnMsg}" 
        error_noExit "[$LINENO]: ${returnMsg}"
fi
msgLine "User Id : $userId assigned to user: dasusr1"


echo "$db2Instance:$db2Pwd" | chpasswd
echo "db2fenc1:$db2Pwd" | chpasswd
echo "dasusr1:$db2Pwd" | chpasswd
msgLine "---------------------------------------"
msgLine "BUILD SUCESSS"
msgLine "End: $(date)"

exit 0
