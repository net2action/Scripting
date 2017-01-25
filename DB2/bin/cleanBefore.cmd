echo off
REM # ----------------------------------------
REM # cleanBefore.cmd
REM #
REM # Author: Andrea Fontana
REM # Mail: afontana@sowre.com 
REM # Documentation: 
REM #
REM # Version: 1.0
REM # Date: 2016-11-24
REM #
REM # License: (C)(R) by SowreSA
REM # ----------------------------------------
echo on


REM # global variables

set logHome=logs                                               REM # nome o path directory log
set Bcp_HOME=D:\Backup                                         REM # backup directory
set JAVA_HOME=D:\IBM\DB2\SQLLIB\java\jdk\bin                   REM # java home
set _robodel=%1\archived                                       REM # working directory
set prefix=cleanBefore                                         REM # nome script


REM # ---------create log --------
if not exist "logs" mkdir logs
for /F "tokens=1-4 delims=/- " %%A in ('date/T') do set DATE=%%B%%C%%D
del /Q %logHome%\%prefix%_%DATE%.log 2> nul
if not exist %logHome%\%prefix%_%DATE%.log type nul> %logHome%\%prefix%_%DATE%.log
set logFile=%logHome%\%prefix%_%DATE%.log
REM # ---------end create log --------




MkDir %_robodel%
ROBOCOPY "%1" %_robodel% /s /move /minage:%2 /np /log+:%logFile%
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set myDate=%%c_%%a_%%b)
echo today is: %myDate%"
echo "Archive Log backup created : %myDate%" > %Bcp_HOME%\read.me
echo "to restore file remeber the phsical path is ..\ from thear" >> %Bcp_HOME%\read.me
echo "use : <JAVA_HOME>\jar -xvf Archive_%myDate%.jar <full_path_file_name> "  >> %Bcp_HOME%\read.me
%JAVA_HOME%\jar -cvf %Bcp_HOME%\Archive_%myDate%.jar %Bcp_HOME%\read.me 
%JAVA_HOME%\jar -uvf %Bcp_HOME%\Archive_%myDate%.jar %_robodel%\* >> %logFile%
rmdir %_robodel% /s /q 
