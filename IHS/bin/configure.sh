#!/bin/bash
# ---------------------------------------------------
#
# version : 1.0.0
#
# Author: AF
#
# by net2action
#
# ---------------------------------------------------

PROGNAME=$(basename $0)
AUTHOR="A.Fontana"
VERSION="1.0.0"
OWNER="(c) by Sowre SA - 2016"




function error_exit
{
        usage
        echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2

        exit 1
}

function usage
{
  echo "*----------------------------------------------------------------------------------"
  echo "| ${OWNER}"
  echo "| Author : ${AUTHOR}"
  echo "| Program : ${PROGNAME} ${VERSION}"
  echo "| ========================== "
  echo "| ${PROGNAME}  [-?|--help -i|--ihsHome -w|--wasHome -e|--env] -f FQDN -d domain"
  echo "|"
  echo "| -e identificate which target you want configure, DX --> for Protal. CNX --> for Connections, STD --> standard Virtual Host "
  echo "|"
  echo "| -i IBM HTTP Server install home, defualt is /opt/IBM/HTTPServer"
  echo "|"
  echo "| -w WAS Intall home default is /opt/IBM/WebSphere/AppServer"
  echo "|"
  echo "| -? this Help"
  echo "|"
  echo "| -f Fully Qualified Domain Name, this paramiter is mandatory, eg. www.sowre.com"
  echo "|"
  echo "| -d mailDomain, this paramiter is mandatory, eg. sowre.com"
  echo "|"
  echo "*----------------------------------------------------------------------------------"
}


ibmHome=/opt/IBM
ihsHome=$ibmHome/HTTPServer
wasHome=$ibmHome/WebSphere/AppServer
environment=STD

# Parse the command-line arguments
while [ "$#" -gt "0" ]; do
  case "$1" in
    -i|--ihsHome)
      ihsHome="$2"
      shift 2
    ;;
    -w|--wasHome)
      wasHome="$2"
      shift 2
    ;;
    -f|--fqdn)
      fqdn="$2"
      shift 2
    ;;
    -d|--domain)
      domain="$2"
      shift 2
    ;; 
    -e|--env)
      environment="$2"
      shift 2
    ;;        
    -*|--*)
      # Unknown option found
	 echo "usage -?|--help to help"
      error_exit "$LINENO: Unknown option $1."
    ;;
    -?|--help)
      usage
    ;;
    *)
      break
    ;;
  esac
done 


if [ "$fqdn" == "" ] ; then
   error_exit "$LINENO: FQDN not specified, -f flag is mandatory"
fi

if [ "$domain" == "" ] ; then
   error_exit "$LINENO: domain not specified, -d flag is mandatory"
fi

#preset environemnt
tar -xvf ../../../pakages/ant197.tgz --directory /opt
export ANT_HOME=/opt/ant
export JAVA_HOME=${ihsHome}/java/jre
export PATH=$PATH:$ANT_HOME/bin:$JAVA_HOME/bin

vh=$(echo $fqdn | awk -F"." '{print $1}')
mkdir -p $ihsHome/conf/vh
mkdir -p $ihsHome/www
mkdir -p $ihsHome/logs/www
mkdir -p $ihsHome/certs
mkdir -p $ihsHome/www/$vh
mkdir -p $ihsHome/logs/www/$vh


cat ../template/includeVhSTD.tmp >> $ihsHome/conf/httpd.conf || error_exit "$LINENO: Can't include ../template/includeVhSTD.tmp into $ihsHome/conf/httpd.conf. "


$wasHome/bin/ws_ant.sh -f ../bin/setHttpd.xml -Dtype=$env -DihsHome=$ihsHome -Dfqdn=$fqdn -Dvh=$vh -Ddomain=$domain

HTTPD=$ihsHome'/bin/apachectl'
var=$($HTTPD -t  2>&1)
status=$(echo $var | cut -d " " -f2)
if [ "$status" != "OK" ]; then
	error_exit "$LINENO: Syntax error in httpd.conf, please check it"
fi