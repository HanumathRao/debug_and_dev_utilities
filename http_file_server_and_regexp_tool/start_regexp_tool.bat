@echo off
cls
echo off
set port=8080
set url=http://localhost:%port%
set server=http_file_server.ps1
set file=regexp_tool.htm
echo %url%| clip
Color 0E 
echo Web server starting at %port%
echo.
echo Browse %url% ( Copied to the clipboard )
echo.
echo Ctrl C for exit
echo.
powershell.exe -executionpolicy bypass -file %server% %file% %port%
pause