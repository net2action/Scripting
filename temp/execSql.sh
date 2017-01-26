#!/bin/bash
<<<<<<< Upstream, based on origin/Linux
<<<<<<< Upstream, based on origin/Linux
 

PROGNAME=$(basename $0)
AUTHOR="A.Fontana"
VERSION="1.0.0"
OWNER=" by net2action 01-2017"
=======

=======
 
>>>>>>> a5a39d6 Temp - Working in Progress - do not use this script

PROGNAME=$(basename $0)
AUTHOR="A.Fontana"
VERSION="1.0.0"
<<<<<<< Upstream, based on origin/Linux
OWNER="(c) by Sowre SA - 2016"
>>>>>>> 8445855 add temporary, Working in Progresss,folder *** do not use this script **
=======
OWNER=" by net2action 01-2017"
>>>>>>> a5a39d6 Temp - Working in Progress - do not use this script

mkdir -p ./log
log=./log/$(echo $PROGNAME | cut -d "." -f 1)
logFile=$log.log
now=$(date)


function error_exit
{
        usage
        echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
        echo "[$now] ${PROGNAME}:[$LINENO] ${1:-"Unknown Error"}" >> ${logFile}
		if [ "$DEBUG" == "1" ] ; then
			msgLine "DEBUG :  Script: $script db: ${DBName} USER ${db2Admin} USING ${db2Pwd}" 1>&2
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



db2Admin=$1
DBName=$2
script=$3
db2Pwd=$4
dataMountPoint=$5

if [ "$DEBUG" == "1" ] ; then
   msgLine "DEBUG : Script: $script db: ${DBName} USER ${db2Admin} USING ${db2Pwd}"
   msgline "1:"$db2Admin " 2: " $DBName "3: " scrpt "4:" $script "uid:" $4 "5:" $dataMountPoint
fi

source ${dataMountPoint}/${db2Admin}/swScript/$3

rc=$?
if [ ${rc} -ne 0 ] ; then
        msgLine "Stream sql command fail:  ${rc}"
        error_exit "$LINENO: Stream sql command [ $script ] fail: ${rc}"
fi

exit $rc
