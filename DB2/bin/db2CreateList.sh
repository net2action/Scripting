#!/bin/bash

now=$(date)
PROGNAME=$(basename $0)
AUTHOR="A.Fontana"
VERSION="1.0.0"
OWNER="net2action - 2016"

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
  echo "| usge : ${PROGNAME} -i db2Instance -o cmdFile -d debug (True/False)"
  echo "|"
  echo "|"
  echo "*----------------------------------------------------------------------------------"
}

msgLine "Create backup command for all database $(date)"

# Parse the command-line arguments
while [ "$#" -gt "0" ]; do
  case "$1" in
    -i)
      db2Instance="$2"
      shift 2
    ;;
    -d)
      DEBUG="$2"
      shift 2
    ;;
    -o)
      cmdFile="$2"
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
msgLine "Your backup will be saved on $backpath"
listaDb=`(db2 list database directory | grep alias | cut -f 2 -d"=" | cut -f 2 -d" ")`

echo "#==================================================================" > $cmdFile
echo "#  database self backup script       " >> $cmdFile
echo "#==================================================================" >> $cmdFile
echo "PROGNAME=\$(basename \$0)"  >> $cmdFile
echo "AUTHOR=\"A.Fontana\""  >> $cmdFile
echo "VERSION=\"1.0.0\""  >> $cmdFile
echo "OWNER=\"net2action - 2016\""  >> $cmdFile
echo "dataHome=/opt/data"  >> $cmdFile
echo "scriptHome=\${dataHome}/swScript"  >> $cmdFile
echo "log=\$scriptHome/log/\$(echo \$PROGNAME | cut -d \".\" -f 1)" >> $cmdFile
echo "logFile=\$log.log" >> $cmdFile

n=0
for i in ${listaDb[@]}; do
    echo "echo backup database $i >> \$logFile" >> $cmdFile
    cmdStato="db2 GET DB CFG FOR  $i  |  grep LOGARCHMETH1 | cut -d \"=\" -f 2"
    if [ "$DEBUG" == "True" ]; then
       msgLine " DEBUG ------> $cmdStato"
    fi
    STATO=$(sh -c "db2 GET DB CFG FOR  $i  |  grep LOGARCHMETH1 | cut -d \"=\" -f 2")
    if [ "$DEBUG" == "True" ]; then
       msgLine " DEBUG --STATO ----> $i --> $STATO"
    fi

    if [ "$STATO" = " OFF" ]; then      
       echo " echo \"This database not configured for hot backup try cold\"  >> \$logFile"  >> $cmdFile
       echo 'su - '$db2Instance'  -c "db2 backup database ' $i ' to '$backpath' with 2 buffers buffer 1024 parallelism 1 compress without prompting;" >> $logFile'  >> $cmdFile
    else
       echo 'su - '$db2Instance'  -c "db2 backup database ' $i ' online to '$backpath' with 2 buffers buffer 1024 parallelism 1 compress include logs without prompting;" >> $logFile'  >> $cmdFile
    fi
done
msgLine "Your self backup script : $cmdFile was created!"

msgLine "---------------------------------------"
msgLine "$PROGNAME    BUILD SUCCESS"
msgLine "End: $(date)"

echo $?
