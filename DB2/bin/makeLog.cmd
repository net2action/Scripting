
if not exist "logs" mkdir logs
set logHome=logs


if "%1"=="" goto default
set prefix=%1
goto setlog
:default
set prefix=Script
goto setlog



:setlog

for /F "tokens=1-4 delims=/- " %%A in ('date/T') do set DATE=%%B%%C%%D
del /Q %logHome%\%prefix%_%DATE%.log 2> nul
if not exist %logHome%\%prefix%_%DATE%.log type nul> %logHome%\%prefix%_%DATE%.log
set logFile=%logHome%\%prefix%_%DATE%.log
timeout /t 5 /NOBREAK