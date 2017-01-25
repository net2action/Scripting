set DBName=%1
set ArchLogPath=%2
set BckOffPath=%3
echo %DBName%

db2 UPDATE DB CFG FOR %DBName% USING logarchmeth1 \"DISK:"%ArchLogPath%"\" logprimary 12 logsecond 20 logfilsiz 4000		
db2 update db cfg for %DBName% using num_db_backups 2
db2 update db cfg for %DBName% using rec_his_retentn 10
db2 update db cfg for %DBName% using auto_del_rec_obj on
db2 BACKUP DATABASE %DBName% TO \"%BckOffPath%\" WITH 2 BUFFERS BUFFER 1024 PARALLELISM 1 COMPRESS  WITHOUT PROMPTING
