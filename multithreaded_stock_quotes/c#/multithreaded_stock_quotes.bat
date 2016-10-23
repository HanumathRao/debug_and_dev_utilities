@ECHO OFF
Color 0E
cls
set CSHARP_COMPILER=C:\Windows\Microsoft.NET\Framework\v3.5\csc.exe
set SOURCE_DIRECTORY=.\src\
set SOURCE_LIST=%SOURCE_DIRECTORY%*.cs
set TARGET=multithreaded_stock_quotes.exe
set SYMBOL_FILE=symbols.txt
IF EXIST %TARGET% del /F %TARGET%
%CSHARP_COMPILER% /out:%TARGET% %SOURCE_LIST%
%TARGET% %SYMBOL_FILE%
pause