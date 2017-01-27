#!/bin/bash

now=$(date)
PROGNAME=$(basename $0)
AUTHOR="A.Fontana"
VERSION="1.0.0"
OWNER="net2action - 2016"
dataHome=/opt/data
scriptHome=${dataHome}/swScript

mkdir -p ${scriptHome}/log
log=${scriptHome}/log/$(echo $PROGNAME | cut -d "." -f 1)
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
  echo "| usge : ${PROGNAME} -i db2Instance"
  echo "|"
  echo "|"
  echo "*----------------------------------------------------------------------------------"
}


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

backpath=/backup/${db2Instance}

mkdir -p $backpath
mkdir -p $scriptHome

msgLine "Your backup will be saved on $backpath"


listaDb=`(db2 list database directory | grep alias | cut -f 2 -d"=" | cut -f 2 -d" ")`
cmdFile=${scriptHome}/bin/db2Backup_${db2Instance}.sh
msgLine "create self backup script : $cmdFile"
echo "#==================================================================" > $cmdFile
echo "#  database self backup script       " >> $cmdFile
echo "#==================================================================" >> $cmdFile
n=0
for i in ${listaDb[@]}; do
    echo $i |
    echo "echo backup database" $i >> $cmdFile
    echo 'su - '$Instance'  -c "db2 backup database ' $i ' online to '$backpath' with 2 buffers buffer 1024 parallelism 1 compress include logs without prompting;"'  >> $cmdFile
done
chmod +x $cmdFile
msgLine "Your self backup script : $cmdFile was created!"

