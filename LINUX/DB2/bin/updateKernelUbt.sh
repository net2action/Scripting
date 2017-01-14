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
  echo "| ${PROGNAME} "
  echo "|"
  echo "*----------------------------------------------------------------------------------"
}
msgLine "Start: $(date)"

mem=$(cat /proc/meminfo | grep MemTotal | cut -d ":" -f 2 | cut -d " " -f 9)
memGb=$(((mem/1024/1024+1)))
memMb=$((memGb*1024))
memb=$((memGb*1024*1024*1024))
pSize=$(getconf -a | grep PAGESIZE | cut -d " " -f 28)
shmall=$((memGb*256))
semmni=$((memGb*256))
msgmni=$((memGb*1024))
writeTo=/etc/sysctl_one.conf

echo "# ----------------------------- " >> $writeTo
echo "kernel.shmmni=$semmni" >> $writeTo
echo "kernel.shmmax=$memb" >> $writeTo
echo "kernel.shmall=$memb" >> $writeTo
echo "#kernel.sem=<SEMMSL> <SEMMNS> <SEMOPM> <SEMMNI>" >> $writeTo
echo "kernel.sem=250 256000 32 $semmni" >> $writeTo
echo "kernel.msgmni=$msgmni" >> $writeTo
echo "kernel.msgmax=65536" >> $writeTo
echo "kernel.msgmnb=65536" >> $writeTo


returnMsg=$(mv $writeTo /etc/sysctl.conf 2>&1 1>/dev/null )
rc=$?
if [ ${rc} -ne 0 ] ; then
        echo "${returnMsg}" 
        error_noExit "[$LINENO]: ${returnMsg}"
fi


msgLine "Reload kernel parameters."

returnMsg=$(sysctl -p 2>&1 1>/dev/null )
rc=$?
if [ ${rc} -ne 0 ] ; then
        echo "${returnMsg}" 
        error_noExit "[$LINENO]: ${returnMsg}"
else
   msgLine "${returnMsg}"
fi


msgLine "Kernel parameters updated and reloaded."
returnMsg=$(ipcs -l 2>&1 1>/dev/null )
rc=$?
if [ ${rc} -ne 0 ] ; then
        echo "${returnMsg}" 
        error_noExit "[$LINENO]: ${returnMsg}"
else
   msgLine "${returnMsg}"
fi

msgLine "---------------------------------------"
msgLine "BUILD SUCESSS"
msgLine "End: $(date)"

exit 0
