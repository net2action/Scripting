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
OWNER="(c) by Net2Action - 2016"

export homeDir=$(pwd)
 

function  error_exit
{
	 usageScript

        echo "${PROGNAME}:[$LINENO] ${1:-"Unknown Error"}"
          
        echo "[$now] ${PROGNAME}:[$LINENO] ${1:-"Unknown Error"}" >> ${logFile}
        exit 1
}

function msgLine
{
        echo "${PROGNAME}:[$LINENO] ${1}" 1>&2
        echo "[$now] ${PROGNAME}:[$LINENO] ${1}" >> ${logFile}
}

function usageScript
{
  echo "*----------------------------------------------------------------------------------"
  echo "| ${OWNER}"
  echo "| Author : ${AUTHOR}"
  echo "| Program : ${PROGNAME} ${VERSION}"
  echo "| ========================== "
  echo "| ${PROGNAME}  [-i db2Admin] -v version id (V10.1 V10.5) -p packPath"
  echo "| -x password -h homePath "
  echo "|"
  echo "| db2Admin : Db2 owner for working directory, default is db2inst1"
  echo "| db2pwd   : Password of Db2 owner, default is P4ssw0rd"
  echo "| homePath : Directory where will be install DB2, default is /opt"
  echo "| version  : V10.1 o V10.5"
  echo "| packPath : complete path where we can find db2Setup command , default is db2inst1"
  echo "|            eg: /media/sf_share/LIX64/db2.10.5.03/server_r"
  echo "*----------------------------------------------------------------------------------"
}

function getOs {
   listaOs=$(cat /etc/os-release | grep NAME | cut -d "=" -f2)
   osCurrent=$(echo $listaOs | tr '"' "." | cut -d "." -f 2  )
   if [ "$osCurrent" == "Ubuntu" ]; then
      os="Ubt"
   fi    

   if [ "$DEBUG" == "True" ]; then
      msgLine "Now we run on: $osCurrent"
   fi
}


mkdir -p ./log
log=${homeDir}/log/$(echo $PROGNAME | cut -d "." -f 1)
export logFile=$log.log
echo > $logFile
msgLine "Start Setup process: $(date)" 

homeDb=/opt
db2Instance=db2inst1
db2Pwd=P4ssw0rd

# Parse the command-line arguments
while [ "$#" -gt "0" ]; do
  case "$1" in
    -i)
      db2Instance="$2"
      shift 2
    ;;
    -h)
      homePath="$2"
      shift 2
    ;;
    -p)
     packPath="$2"
      shift 2
    ;;       
    -x)
     db2Pwd="$2"
      shift 2
    ;;       
    -v)
     version="$2"
      shift 2
    ;;       
    -?|--help)
      usageScript
    exit 0
    ;;
    *)
      break
    ;;
  esac
done

getOs

fenUid=$(id -u db2fenc1)
uid=$(id -u $db2Instance)
dasUid=$(id -u dasusr1)

if [ "$version" == "" ] ; then
 error_exit "$LINENO: Missing, Db2 version, -v flag is mandatory"
fi

if [ "$packPath" == "" ] ; then
 error_exit "$LINENO: Missing, Db2 version, -p flag is mandatory"
fi

$homeDir/bin/createUsersGroup${os}.sh -p ${db2Pwd}
rc=$?
if [ ${rc} -eq 0 ] ; then
   $homeDir/bin/presetDb2Env${os}.sh
   rc=$?
   if [ ${rc} -eq 0 ] ; then
      $homeDir/bin/setHost${os}.sh dbstore.ondemand.com
      rc=$?
      if [ ${rc} -eq 0 ] ; then
         $homeDir/bin/updateKernel${os}.sh
         rc=$?
        if [ ${rc} -eq 0 ] ; then
                $homeDir/bin/installDb2.sh -v ${version} -p ${packPath}
         fi
      fi
   fi
fi
exit
$homeDir/bin/createDxDb.sh -db2Admin ${db2Instance} -password ${db2Pwd}
$homeDir/bin/setHotBackup.sh -i ${db2Instance}
$homeDir/bin/schedulateBcp.sh -i ${db2Instance} -timeString "30 0 * * 1"

