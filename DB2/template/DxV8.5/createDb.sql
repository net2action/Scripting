#------------------------------------------------
# this script create DX Db via streaming command
# Author: AF - 2016-03-26
# Owner: Net2Action
#------------------------------------------------
#CONNECT TO ${DBName};
#GRANT DBADM, SECADM ON DATABASE TO USER ${db2Admin};
#CONNECT RESET;

if [ "$DEBUG" == "True" ] ; then
   echo " db: " ${DBName} "--"  ${db2Admin}
fi

db2 -t -x -z sql.out +p <<-eof
CREATE DB ${DBName} ON ${dataMountPoint} using codeset UTF-8 territory us PAGESIZE 8192;
UPDATE DB CFG FOR ${DBName} USING locktimeout 30;
terminate;
eof
