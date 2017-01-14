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

function usageScript
{
  echo "*----------------------------------------------------------------------------------"
  echo "| ${OWNER}"
  echo "| Author : ${AUTHOR}"
  echo "| Program : ${PROGNAME} ${VERSION}"
  echo "| ========================== "
  echo "| ${PROGNAME}  [-i db2Admin] [-h homePath] -v version id (V10.1 V10.5) -p packPath"
  echo "| -s smtpServer"
  echo "|"
  echo "| homePath : Path where DB2 will be install, default is /opt/ibm"
  echo "| smtpServer : insert your smtp Server fqdn"
  echo "| db2Admin : Db2 owner for working directory, default is db2inst1"
  echo "| packPath : complete path where we can find db2Setup command , default is db2inst1"
  echo "|            eg: /media/sf_share/LIX64/db2.10.5.03/server_r"
  echo "*----------------------------------------------------------------------------------"
}

msgLine "Install DB2 begin at $(date)"

homeDb2=/opt/ibm
db2Instance=db2inst1

# Parse the command-line arguments
while [ "$#" -gt "0" ]; do
  case "$1" in
    -i)
      db2Instance="$2"
      shift 2
    ;;
    -h)
      homeDb2="$2"
      shift 2
    ;;
    -p)
     packPath="$2"
      shift 2
    ;;       
    -s)
     smtp="$2"
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

fenUid=$(id -u db2fenc1)
uid=$(id -u $db2Instance)
dasUid=$(id -u dasusr1)

if [ "$version" == "" ] ; then
 error_exit "$LINENO: Missing, Db2 version, -v flag is mandatory"
fi

if [ "$packPath" == "" ] ; then
 error_exit "$LINENO: Missing, Db2 version, -p flag is mandatory"
fi

rspOut=${homeDir}/work/db2.rsp
mkdir -p ${homeDir}/work
from=${homeDir}/template/db2ese$version.rsp

cp $from $rspOut

rc=$?
if [ ${rc} -ne 0 ] ; then
	echo "Copy file from $from to $rspOut fail ${rc}" 
	error_exit "$LINENO: Copy file from $from to $rspOut fail ${rc}"
fi


## Escape path for sed using bash find and replace 
homeDb2="${homeDb2//\//\\/}"
 
sed -i -e 's/@db2Instance@/'${db2Instance}'/g' $rspOut 
sed -i -e 's/@fenUid@/'${fenUid}'/g' $rspOut 
sed -i -e 's/@uid@/'${uid}'/g' $rspOut
sed -i -e 's/@dasUid@/'${dasUid}'/g' $rspOut
sed -i -e 's/@fenUid@/'${fenUid}'/g' $rspOut
sed -i -e 's/@mailServer@/'${smtp}'/g' $rspOut
sed -i -e 's/@homeDb2@/'${homeDb2}'/g' $rspOut


returnMsg=$($packPath/db2setup -r $rspOut -l  2>&1 1>/dev/null )
echo "${returnMsg}" 
rc=$?
if [ ${rc} -ne 0 ] ; then
	echo "Install DB2 Fail using $rspOut response file ${rc}" 
	error_exit "$LINENO: Install DB2 Fail using $rspOut response file ${rc}"
fi

su - ${db2Instance} -c "db2start"

msgLine "---------------------------------------"
msgLine "BUILD SUCESSS"
msgLine "End: $(date)"

exit 0
