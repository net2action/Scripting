#!/bin/bash


PROGNAME=$(basename $0)
AUTHOR="A.Fontana"
VERSION="1.0.0"
OWNER=" by net2action - 2016"

now=$(date)
 
db2Admin=$1
DBName=$2
script=$3
db2Pwd=$4
dataMountPoint=$5


if [ -z "$logFile" ]; then
   mkdir -p ./log
   log=./log/$(echo $PROGNAME | cut -d "." -f 1)
   logFile=$log.log
fi


function error_exit
{
        echo "${PROGNAME}:[$LINENO] ${1}"
        echo "[$now] ${PROGNAME}:[$LINENO] ${1}" >> ${logFile}
        msgLine "---------------------------------------"
        echo "BUILD FAIL"
        if [ "$DEBUG" == "True" ] ; then
	    msgLine " DEBUG ------> Script: $script db: ${DBName} USER ${db2Admin} USING ${db2Pwd}" 1>&2
	fi
      exit ${rc}
}

function usage
{
  echo "*----------------------------------------------------------------------------------"
  echo "| ${OWNER}"
  echo "| Author : ${AUTHOR}"
  echo "| Program : ${PROGNAME} ${VERSION}"
  echo "| ========================== "
  echo "| this script rerun sql commqnd via streaming"
  echo "|"
  echo "*----------------------------------------------------------------------------------"
}

function msgLine
{
        echo "${PROGNAME}:[$LINENO] ${1}" 1>&2
        echo "[$now] ${PROGNAME}:[$LINENO] ${1}" >> ${logFile}
}


if [ "$DEBUG" == "True" ] ; then
   msgLine " DEBUG ------>  Script: $script db: ${DBName} USER ${db2Admin} USING ${db2Pwd}"
   msgline "1:"$db2Admin " 2: " $DBName "3: " scrpt "4:" $script "uid:" $4 "5:" $dataMountPoint
fi

source ${dataMountPoint}/${db2Admin}/swScript/$3

rc=$?
if [ ${rc} -ne  0 ] ; then
        msgLine "Stream sql command fail:  ${rc}"
        error_exit "$LINENO: Stream sql command [ $script ] fail: ${rc}"
fi

msgLine "---------------------------------------"
msgLine "$PROGNAME    BUILD SUCCESS"
msgLine "End: $(date)"
exit $rc

