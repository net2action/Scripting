#!/bin/bash

now=$(date)
PROGNAME=$(basename $0)
AUTHOR="A.Fontana"
VERSION="1.0.0"
OWNER="net2action - 2016"
dataHome=/opt/data
scriptHome=${dataHome}/swScript

mkdir -p ../log
log=../log/$(echo $PROGNAME | cut -d "." -f 1)
logFile=$log.log



function error_exit
{
	 usage

        echo "${PROGNAME}:[$LINENO] ${1:-"Unknown Error"}"
          
        echo "[$now] ${PROGNAME}:[$LINENO] ${1:-"Unknown Error"}" >> ${logFile}
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

msgLine "Start: $(date)"

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

su - ${db2Instance} -c "${scriptHome}/bin/db2CreateList.sh -i ${db2Instance}"
${scriptHome}/bin/db2Backup_${db2Instance}.sh

msgLine "End: $(date)"

