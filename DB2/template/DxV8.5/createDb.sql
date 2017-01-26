#------------------------------------------------
# this script create DX Db via streaming command
# Author: AF - 2016-03-26
# Owner: Net2Action
#------------------------------------------------
#CONNECT TO ${DBName};
#GRANT DBADM, SECADM ON DATABASE TO USER ${db2Admin};
#CONNECT RESET;

PROGNAME=$(basename $0)
AUTHOR="A.Fontana"
VERSION="1.0.0"
OWNER=" by net2action - 2016"


function error_exit
{
        echo "${PROGNAME}:[$LINENO] ${1}"
        echo "[$now] ${PROGNAME}:[$LINENO] ${1}" >> ${logFile}
        msgLine "---------------------------------------"
        echo "BUILD FAIL"
        if [ "$DEBUG" == "True" ] ; then
	    msgLine " DEBUG ------>  Script: $script db: ${DBName} USER ${db2Admin} USING ${db2Pwd}" 1>&2
	fi
        exit ${rc}
}

function msgLine
{
        echo "${PROGNAME}:[$LINENO] ${1}" 1>&2
        echo "[$now] ${PROGNAME}:[$LINENO] ${1}" >> ${logFile}
}


if [ "$DEBUG" == "True" ] ; then
   msgLine " DEBUG ------>  db:  ${DBName} --  ${db2Admin}"
fi

db2 -t -x -z sql.out +p <<-eof
CREATE DB ${DBName} ON ${dataMountPoint} using codeset UTF-8 territory us PAGESIZE 8192;
UPDATE DB CFG FOR ${DBName} USING locktimeout 30;
terminate;
eof

rc=$?
if [ ${rc} -ne  0 ] ; then
        msgLine "Stream sql command fail:  ${rc}"
        error_exit "$LINENO: Stream sql command [ $script ] fail: ${rc}"
fi

msgLine "---------------------------------------"
msgLine "$PROGNAME    BUILD SUCCESS"
msgLine "End: $(date)"

exit 0
