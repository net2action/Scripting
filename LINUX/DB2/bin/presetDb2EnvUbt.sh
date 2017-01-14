#!/bin/bash
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

function usage
{
  echo "*----------------------------------------------------------------------------------"
  echo "| ${OWNER}"
  echo "| Author : ${AUTHOR}"
  echo "| Program : ${PROGNAME} ${VERSION}"
  echo "| ========================== "
  echo "| ${PROGNAME}  [-b backupPath] [-i db2Admin] [-a archiveLogPath]"
  echo "|"
  echo "| backupPath : Path where will be put backup images, default is /backup"
  echo "| archiveLogPath : Path where will be put archive logs images, default is /archiveLogs"
  echo "| db2Admin : Db2 owner for working directory, default is db2inst1"
  echo "|"
  echo "*----------------------------------------------------------------------------------"
}

msgLine "Preset environment for DB2 begin at $(date)"

bckPath=/backup
db2Admin=db2inst1
alPath=/archiveLogs

# Parse the command-line arguments
while [ "$#" -gt "0" ]; do
  case "$1" in
    -i)
      db2Admin="$2"
      shift 2
    ;;
    -a)
      alPath="$2"
      shift 2
    ;;    
    -b)
      bckPath="$2"
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



mkdir -p ${alPath}
rc=$?
if [ ${rc} -ne 0 ] ; then
    echo "Create backup directory ${alPath} fail ${rc}"
        error_exit "Create backup directory ${alPath} fail ${rc}"
fi

chmod 775 ${alPath}
chown  ${db2Admin} ${alPath}

mkdir -p ${bckPath}
rc=$?
if [ ${rc} -ne 0 ] ; then
    echo "Create backup directory ${bckPath} fail ${rc}" 
        error_exit "Create backup directory ${bckPath} fail ${rc}"
fi

chmod 775 ${bckPath}
chown  ${db2Admin} ${bckPath}


msgLine "---------------------------------------"
msgLine "BUILD SUCESSS"
msgLine "End: $(date)"

exit 0
