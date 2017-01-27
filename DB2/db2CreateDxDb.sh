#!/bin/bash
 
# ---------------------------------------------------
#
# version : 1.0.0
#
# Author: AF  a.fontana@net2action.com
#
# by Net2Action 
#
# ---------------------------------------------------

now=$(date)
PROGNAME=$(basename $0)
AUTHOR="A.Fontana"
VERSION="1.0.0"
OWNER="by net2action - 2016"




dataHome=/opt/data
home=$(pwd)

inDbList[0]=wpsdb
inDbList[1]=wpsdb
inDbList[2]=wpsdb
inDbList[3]=jcrDb
inDbList[4]=lmkDb
inDbList[5]=fdbkDb


if [ -z "$logFile" ]; then
   mkdir -p ./log
   log=./log/$(echo $PROGNAME | cut -d "." -f 1)
   logFile=$log.log
fi

function getSortedDbList {
if [ "$DEBUG" == "True" ]; then
   msgLine " DEBUG ------> List db to be sorted: ${dbList[@]}"
fi


     if [ "$dbList" != "" ]; then
        listDb=$dbList
	set -f # avoid globbing (expansion of *).
	array=(${listDb//:/ })
	for i in "${!array[@]}"
	do
    		dbName=$(echo ${array[i]} | cut -d "=" -f 2)
  		listaDb=(${listaDb[@]} "$dbName")
                if [ "$DEBUG" == "True" ]; then
    		   msgLine " DEBUG ------>  $i=>${array[i]} my db is: $dbName"
                fi 
	done
        sortDbList=($(echo "${listaDb[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
     else
        if [ "$DEBUG" == "True" ]; then
          for i in ${!inDbList[@]}
          do
            msgLine " DEBUG                          ----> $i ---> ${inDbList[$i]}"
          done
        fi
        sortDbList=($(echo "${inDbList[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
     fi

if [ "$DEBUG" == "True" ]; then
   msgLine " DEBUG ------> Sorted db list :"
   for i in "${!sortDbList[@]}"
   do
      msgLine " DEBUG                          ----> $i=>>>${sortDbList[i]}" 
   done



fi

}

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
  echo "| usge : ${PROGNAME} -i db2inst1 -x xxxxxxxx -dbList yyyyy"
  echo "|"
  echo "| dbLsit = <schemaDbName=dbname:schemaDbName=dbname:......"
  echo "| relDBName=<dbname>:comDbName=<dbname>:custDbName=<dbname>:jcrDbName=<dbname>:lmDbName=<dbname>:fdbkDbName=<dbname>"
  echo "*----------------------------------------------------------------------------------"
}

msgLine "Create DX Database begin at $(date)"

# Parse the command-line arguments
while [ "$#" -gt "0" ]; do
  case "$1" in
    -i)
      db2Admin="$2"
      shift 2
    ;;
    -x)
      db2Pwd="$2"
      shift 2
    ;;
    -dbList)
      dbList="$2"
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

if [ "$db2Admin" == "" ] ; then
 error_exit "$LINENO: Missing, Db2 Admin id, -db2Admin flag is mandatory"
fi

if [ "$db2Pwd" == "" ] ; then
 error_exit "$LINENO: Missing, Db2 Admin password, -password flag is mandatory"
fi

chmod a+w ${logFile}

homedir=$( getent passwd "${db2Admin}" | cut -d: -f6 )
scriptDir=$homedir/swScript

mkdir -p $scriptDir
chmod -R 777 $scriptDir

if [ "$DEBUG" == "True" ]; then
   esi=$(ls -la $scriptDir)
   msgLine " DEBUG ------> ${esi}" 

fi



from="${home}/template/DxV8.5/createDb.sql"
cp $from $scriptDir
rc=$?
if [ ${rc} -ne 0 ] ; then
	echo "Copy file from $from to $scriptDir fail ${rc}" 
	error_exit "$LINENO: Copy file from $from to $scriptDir fail ${rc}"
fi

from="${home}/template/DxV8.5/extendJcrDb.sql"
cp $from $scriptDir
rc=$?
if [ ${rc} -ne 0 ] ; then
	echo "Copy file from $from to $scriptDir fail ${rc}" 
	error_exit "$LINENO: Copy file from $from to $scriptDir fail ${rc}"
fi

from="${home}/bin/execSql.sh"
cp $from $scriptDir
rc=$?
if [ ${rc} -ne 0 ] ; then
	echo "Copy file from $from to $scriptDir fail ${rc}" 
	error_exit "$LINENO: Copy file from $from to $scriptDir fail ${rc}"
fi

from="${home}/bin/presetDb2ForDx.sh"
cp $from $scriptDir
rc=$?
if [ ${rc} -ne 0 ] ; then
	echo "Copy file from $from to $scriptDir fail ${rc}" 
	error_exit "$LINENO: Copy file from $from to $scriptDir fail ${rc}"
fi

chmod 777 $scriptDir/*

echo "-----------Create Database----------------" >> ${logFile}

currentDb=""

getSortedDbList

if [ "$DEBUG" == "True" ]; then
   msgLine " DEBUG ------> List database will be create: ${sortDbList[@]}"
fi

if [ "${sortDbList[0]}" == "" ]; then
   error_exit "$LINENO: your Db List is empty. "
fi

for DBName in "${sortDbList[@]}"
do
        if [ "$currentDb" != "$DBName" ] ; then
                currentDb=$DBName
        msgLine "Create DB : $DBName" ${logFile}
    	cmd="$scriptDir/execSql.sh ${db2Admin} $DBName createDb.sql $db2Pwd $dataHome"
        if [ "$DEBUG" == "True" ]; then
           msgLine " DEBUG ------> Script Home:    $scriptDir"
           msgLine " DEBUG ------> Execute command: $cmd"
        fi
    	su - ${db2Admin} -c "$cmd" >> ${logFile} 
        rc=$?
                if [ ${rc} -ne 0 ] ; then
                        msgLine "setup database $DBName returns ${rc}" 
                        error_exit "$LINENO: Setup database $DBName returns ${rc}"
                fi
        fi
        if [ "$DBName" == "$jcrDbName" ] ; then
        	cmd="${scriptDir}/execSql.sh ${db2Admin} $DBName extendJcrDb.sql $db2Pwd $dataHome"
		if [ "$DEBUG" == "True" ]; then
                   msgLine " DEBUG ------> Script Home:    $scriptDir"
                   msgLine " DEBUG ------> Execute command: $cmd"
		fi
            su - ${db2Admin} -c "$cmd"  >> ${logFile}
                rc=$?
                if [ ${rc} -ne 0 ] ; then
                        msgLine "Extend database $DBName returns ${rc}" 
                        error_exit "$LINENO: Extend database $DBName returns ${rc}"
                fi
        fi
done

su - ${db2Admin} -c "${scriptDir}/presetDb2ForDx.sh" >> ${logFile}

if [ "$DEBUG" != "True" ] ; then
	rm -rf $scriptDir
fi

msgLine "---------------------------------------"
msgLine "$PROGNAME    BUILD SUCCESS"
msgLine "End: $(date)"
echo $?

