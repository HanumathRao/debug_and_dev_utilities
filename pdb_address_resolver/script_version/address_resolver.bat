@echo off
powershell.exe -executionpolicy bypass -file ".\address_resolver.ps1" %1 %2
pause