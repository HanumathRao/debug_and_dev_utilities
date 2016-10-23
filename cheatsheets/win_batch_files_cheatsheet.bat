REM @echo off disables echoing every command being executed
@echo off
REM Setting script directory as working directory
cd /d %~dp0
REM Clear Screen
cls
REM Set foreground color to yellow
Color 0E

REM IF-ELSE & args , print 1st arg if exists
IF NOT [%1]==[] ( echo %1 )

REM Set and use a variable & directory checking
set DIRECTORY_NAME=BLABLA
if NOT EXIST %DIRECTORY_NAME% echo %DIRECTORY_NAME% does not exist

REM Prompting and assigning the entered value back to a variable
set /p USER_VALUE= Enter a number : 
echo %USER_VALUE%

REM Temporily adding a variable to PATH variable
path=%path%;c:\foo
echo %path%

REM Calling functions
call:info_message "arg1" "arg2"
call:info_message "arg3" "arg4"

REM FOR LOOPS , 1:start , 1:increment , 5:end
FOR /L %%A IN (1,1,5) DO (
  ECHO %%A
)

REM FOR LOOP IN A FILE :
REM Display each line in test.cfg if it exists a file
REM and ignore lines starting with #
for /f "delims=#" %%P in (install.cfg) do (
    cmd /c if exist %%P echo %%P
)

REM COPYING FILE BY OVERWRITING
REM copy /y file destination_directory
REM DELETE FILE IF EXISTS
REM IF EXIST %TARGET% del /F %TARGET%

REM EXECUTING A POWERSHELL SCRIPT
powershell.exe -executionpolicy bypass -file ./target_script.ps1

REM Exit Point
REM Press a key to exit
pause
goto:eof

REM Function has to be surrounded with goto:eof
:info_message: 
ECHO %~1 %~2
goto:eof

:sub_heading: 
echo.
echo -------------------------------------------------------------------------------
echo -------------------------------------------------------------------------------
echo %~1
echo -------------------------------------------------------------------------------
echo -------------------------------------------------------------------------------
goto:eof