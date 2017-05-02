@echo off
SET WINDBG="C:\Program Files (x86)\Windows Kits\10\Debuggers\x86\windbg.exe"
SET WINDBG_SCRIPT=~dp0windbg_script.txt
SET WINDBG_WORKSPACE="SQLSRV"
SET DEBUGEE=php-cgi.exe

:WAIT_FOR_PROCESS
FOR /F %%x IN ('tasklist /NH /FI "IMAGENAME eq %DEBUGEE%"') DO IF %%x == %DEBUGEE% goto ATTACH_TO_PROCESS
cls
echo Waiting for process to start
goto WAIT_FOR_PROCESS
:ATTACH_TO_PROCESS
echo Attaching to the process with Winbg
%WINDBG% -pn %DEBUGEE% -W %WINDBG_WORKSPACE% -c "$<%%WINDBG_SCRIPT%"