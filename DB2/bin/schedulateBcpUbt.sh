#!/bin/bash

now=$(date)
PROGNAME=$(basename $0)
AUTHOR="A.Fontana"
VERSION="1.0.0"
OWNER="(c) by Sowre SA - 2016"
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
  echo "| usge : ${PROGNAME} -i db2Instance -myTimeString default is : 30 0 * * *"
  echo "|"
  echo "|"
  echo "*----------------------------------------------------------------------------------"
}

msgLine "Schedule backup script at $(date)"

myTime="30 0 * * *"

# Parse the command-line arguments
while [ "$#" -gt "0" ]; do
  case "$1" in
    -i)
      db2Instance="$2"
      shift 2
    ;;
    -myTimeString)
     myTime="$2"
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


#echo new cron into cron file
myCron="${myTime} root ${scriptHome}/db2FullBackp.sh"
msgLine "Your backup will be schedule at : ${myCron}"

#write out current crontab
crontab -l > /tmp/mycron
#echo new cron into cron file
echo "$myCron" >> /tmp/mycron
#install new cron file
crontab /tmp/mycron
rm /tmp/mycron


from=../template/db2Service
to=/etc/init.d/db2_$db2Instance
cp $from $to

rc=$?
if [ ${rc} -ne 0 ] ; then
	echo "Copy file from $from to $rspOut fail ${rc}" 
	error_exit "$LINENO: Copy file from $from to $rspOut fail ${rc}"
fi

sed -i -e 's/@db2admin@/'${db2Instance}'/g' $to 

chmod +x $to

msgLine "---------------------------------------"
msgLine "$PROGNAME    BUILD SUCCESS"
msgLine "End: $(date)"

echo $?

