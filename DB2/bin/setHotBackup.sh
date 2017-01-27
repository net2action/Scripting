#!/bin/bash

now=$(date)
PROGNAME=$(basename $0)
AUTHOR="A.Fontana"
VERSION="1.0.0"
OWNER="(c) by net2action - 2016"

dataHome=/opt/data
scriptHome=${dataHome}/swScript

if [ -z "$logFile" ]; then
   mkdir -p ./log
   log=./log/$(echo $PROGNAME | cut -d "." -f 1)
   logFile=$log.log
fi	

function error_exit
{
        usage
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

function usage
{
  echo "*----------------------------------------------------------------------------------"
  echo "| ${OWNER}"
  echo "| Author : ${AUTHOR}"
  echo "| Program : ${PROGNAME} ${VERSION}"
  echo "| ========================== "
  echo "| usge : ${PROGNAME} -i db2Instance "
  echo "|"
  echo "|"
  echo "*----------------------------------------------------------------------------------"
}

msgLine "Set Database for hot backup begin at $(date)"


# Parse the command-line arguments
while [ "$#" -gt "0" ]; do
  case "$1" in
    -i)
      db2Instance="$2"
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
    error_exit "$LINENO: Missing, Db2 Instance name, -i flag is mandatory"
fi

instanceName=$db2Instance
instanceOwner=$(echo $instanceName | tr '[:lower:]' '[:upper:]')
bck=/backup
archiveLogPath=/archiveLogs


if [ "$DEBUG" == "True" ]; then
         msgLine " DEBUG ------>   $scriptHome"
fi


mkdir -p $scriptHome
chmod -R 777 $scriptHome


# Functions



function quit() {
     echo $rc
     exit
}

function setHot() {
   msgLine "preset database  $1 to archive log, in  $archiveLogPath"
   su - $instanceName -c "db2 UPDATE DB CFG FOR $1 USING logarchmeth1 \"DISK:\"$archiveLogPath\"\" logprimary 12 logsecond 20 logfilsiz 4000"		
   su - $instanceName -c "db2 update db cfg for $1 using num_db_backups 2"
   su - $instanceName -c "db2 update db cfg for $1 using rec_his_retentn 10"
   su - $instanceName -c "db2 update db cfg for $1 using auto_del_rec_obj on"
   su - $instanceName -c "db2 BACKUP DATABASE $1 TO \"$bck\" WITH 2 BUFFERS BUFFER 1024 PARALLELISM 1 COMPRESS  WITHOUT PROMPTING"
   msgLine 'Database ' $1' configure to archive log, in ' $archiveLogPath ' and permit Hot Backup'

}

msgLine "Preset database for hot backup begin at $(date)"


msgLine "crete ArchiveLog directroy"
mkdir -p ${archiveLogPath}
chown $instanceName ${archiveLogPath}

msgLine "create Backup directory"
mkdir -p ${bck}
chown $instanceName ${bck}

listadb=$(su - $instanceName -c 'db2 list database directory | grep alias | cut  -f 2 -d"=" | cut -f 2 -d" "')
sortDbList=($(echo "${listadb[@]}" | sort -u | tr '\n' ' '))
if [ "$DEBUG" == "True" ]; then
	msgLine " DEBUG ------>  ${sortDbList[@]}"
fi   		


for i in ${sortDbList[@]}; do
	STATO=$(su - $instanceName -c 'db2 GET DB CFG FOR  '$i'  |  grep LOGARCHMETH1 | cut -d "=" -f 2')
        if [ "$DEBUG" == "True" ]; then
	    msgLine " DEBUG ------> $i --> $STATO"
        fi
	if [ "$STATO" = " OFF" ]; then                
         setHot $i
    fi
done

from="./db2Full*.sh"
cp $from $scriptHome
rc=$?
if [ ${rc} -ne 0 ] ; then
	msgLine "Copy file from $from to $scriptHome fail ${rc}" 
	error_exit "$LINENO: Copy file from $from to $scriptHome fail ${rc}"
fi

from="./db2CreateList.sh"
cp $from $scriptHome
rc=$?
if [ ${rc} -ne 0 ] ; then
	msgLine "Copy file from $from to $scriptHome fail ${rc}" 
	error_exit "$LINENO: Copy file from $from to $scriptHome fail ${rc}"
fi

msgLine "---------------------------------------"
msgLine "$PROGNAME    BUILD SUCCESS"
msgLine "End: $(date)"

echo $?