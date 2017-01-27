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

function warnigExit
{
        echo "${PROGNAME}:[$LINENO] ${1}"
        echo "[$now] ${PROGNAME}:[$LINENO] ${1}" >> ${logFile}
        exit 0
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
  echo "| ${PROGNAME} -i db2Admin -l licensePath"
  echo "|"
  echo "| licensPath : complete path where we can find db2esexxx.lic file"
  echo "|            eg: /media/sf_share/LIX64/db2.10.5.03/server_r"
  echo "*----------------------------------------------------------------------------------"
}


mkdir -p ./log
log=${homeDir}/log/$(echo $PROGNAME | cut -d "." -f 1)
export logFile=$log.log
echo > $logFile
msgLine "Start Setup process: $(date)" 

# Parse the command-line arguments
while [ "$#" -gt "0" ]; do
  case "$1" in
    -l)
      db2Lic="$2"
      shift 2
    ;;
    -i)
      db2Admin="$2"
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

if [ "$db2Lic" == "" ] ; then
 warnigExit "$LINENO: Missing, Db2 License, remember you have 90 days to update it"
fi

if [ "$db2Admin" == "" ] ; then
 error_exit "$LINENO: Missing, Db2 Admin id, -db2Admin flag is mandatory"
fi

su - ${db2Admin} -c "db2licm -a ${db2Lic}" >> ${logFile}
su - ${db2Admin} -c "db2licm -l" >> ${logFile}
su - ${db2Admin} -c "db2licm -l" >> ${logFile}

msgLine "---------------------------------------"
msgLine "$PROGNAME    BUILD SUCCESS"
msgLine "End: $(date)"
echo $
