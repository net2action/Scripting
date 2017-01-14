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
  echo "| usge : ${PROGNAME} -f FQDN eg. ${PROGNAME} dbstore.ondemand.com"
  echo "| defualt is dbstore01.ondemand.com"
  echo "|"
  echo "*----------------------------------------------------------------------------------"
}

msgLine "Set hostname  begin at $(date)"

fqdn=dbstore.ondemand.com

# Parse the command-line arguments
while [ "$#" -gt "0" ]; do
  case "$1" in
    -f)
     fqdn="$2"
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

ipAddress=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

if [ "$ipAddress" == "" ] ; then
	echo "Get ip address fail, pelase check your network configuration ${rc}"
	error_exit "$LINENO: Get ip address fail, pelase check your network configuration ${rc}"
fi	
	

returnMsg=$(hostnamectl set-hostname $fqdn 2>&1 1>/dev/null )
rc=$?
if [ ${rc} -ne 0 ] ; then
	echo "Set hostname $fqdn fail ${rc} ${returnMsg}" 
	error_exit "$LINENO: Set hostname $fqdn fail ${rc} ${returnMsg}"
fi

existIp=$(getent hosts ${ipAddress} | cut -d " " -f 1)
sF=$(getent hosts ${ipAddress})
solveFqdn=$(sed -e 's/[[:space:]]*$//' <<<${sF} | cut -d " " -f 8)
eF=$(getent hosts ${fqdn})
existFqdn=$(sed -e 's/[[:space:]]*$//' <<<${eF} | cut -d " " -f 2)
solveIp=$(getent hosts ${fqdn} | cut -d " " -f 1)

msgLine "Ip: $existIp solved with $solveFqdn"
msgLine "Fqdn: $existFqdn solved by $solveIp"




if [ -z "$existIp" ] && [ -z "$existFqdn" ] ; then
   echo "# --------------------------------------" >> /etc/hosts
   echo "# added by Net2Action Scripting do not remove " >> /etc/hosts
   echo "# --------------------------------------" >> /etc/hosts
   echo $ipAddress  $fqdn >> /etc/hosts
else
   if [ ! -z "$existIp" ];then
      if [ "$fqdn" != "$existFqdn" ] && [ "$fqdn" != "$solveFqdn" ] ; then
         error_exit "Your IP: $ipAddress  already present, it's resolve with ${solveFqdn}, can't continue"
      fi
   fi

   if [ ! -z "$existFqdn" ];then
      if [ "$ipAddress" != "$existIp" ]; then
         error_exit "Your fqdn: $fqdn already present, it's resolve with ${solveIp}, can't continue"
      fi
   fi
fi
msgLine "---------------------------------------"
msgLine "BUILD SUCESSS"
msgLine "End: $(date)"

exit 0
