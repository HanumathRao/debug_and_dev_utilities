<td><img src="https://img.shields.io/badge/LICENCE-PUBLIC%20DOMAIN-green.svg" alt="Licence badge"></td>

===========================================================================

In this repository I will collect various utility scripts/code and some cheatsheets.

**memory_leak_detector ( Python ):** memdump.py is a GDB extension written in Python. It dumps all memory operations done by GNU LibC Runtime ( malloc, realloc, calloc and free),
with their information ( arguments, callstacks and return value) by automating GDB. Memleak.py detects memory leaks analyzing output
of memdump.py. You can use memleak.sh to detect memory leaks at one go as it calls both memdump.py and memleak.py.

Detailed blog post : https://nativecoding.wordpress.com/2016/07/31/gdb-debugging-automation-with-python/

**cpp_reflection_tool ( Python ) :** It is  simple Python script which uses Clang , in order to create a header file
with metadata of target source file.

Detailed blog post : https://nativecoding.wordpress.com/2016/10/25/c-reflection-using-clang/

**multithreaded_stock_quotes ( Python / C# / Powershell ):** It is for querying stock quotes on multicore systems using Yahoo Finance API. It has been implemented seperately in Python (2.7) , C# and also as a standalone Powershell script which uses C# code. C# code can also run on Linux ( Mono ). A makefile for Mono/Linux is provided. Also you can use a bat file for Windows C# version which compiles and runs the project in command line by using C# compiler that is shipped with Windows.