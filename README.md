Licence : All samples are "Public Domain" code 
http://en.wikipedia.org/wiki/Public_domain_software

https://img.shields.io/badge/LICENCE-PUBLIC%20DOMAIN-green.svg

===========================================================================

In this repository I will collect various utility scripts/code and sone cheatsheets.

**memory_leak_detector ( Python ):** memdump.py is a GDB extension written in Python. It dumps all memory operations done by GNU LibC Runtime ( malloc, realloc, calloc and free),
with their information ( arguments, callstacks and return value) by automating GDB. Memleak.py detects memory leaks analyzing output
of memdump.py. You can use memleak.sh to detect memory leaks at one go as it calls both memdump.py and memleak.py.

Detailed blog post : https://nativecoding.wordpress.com/2016/07/31/gdb-debugging-automation-with-python/

**cpp_reflection_tool ( Python ) :** It is  simple Python script which uses Clang , in order to create a header file
with metadata of target source file.

Detailed blog post : https://nativecoding.wordpress.com/2016/10/25/c-reflection-using-clang/

**multithreaded_stock_quotes ( Python / C# / Powershell ):** It is for querying stock quotes on multicore systems using Yahoo Finance API. It has been implemented seperately in Python (2.7) , C# and also as a standalone Powershell script which uses C# code. C# code can also run on Linux ( Mono ). A makefile for Mono/Linux is provided. Also you can use a bat file for Windows C# version which compiles and runs the project in command line by using C# compiler that is shipped with Windows.

**http_file_server_and_regexp_tool ( Python & Powershell & Javascript):** Python and Powershell implementations have a minimal HTTP server that serves a single file. And regexp tool is written in Javascript using JQueryUI. It generates extended GNU regular expressions. Using together gives us a tool that works via browser.

**tcp_client_server ( Python / Bash / Powershell ) :** Linux Bash scripts tested on Debian and Linux TCP server requires netcat utility. Windows Powershell scripts uses .Net Framework. Python server uses SocketServer.

**multiprocess ( Python / Bash / Powershell ) :** It has multiprocessing templates. Python have 2 implementations with subprocesses and threads.

**source_code_formatter ( Bash ):** Linux Bash script that acts on cpp,h,hpp files by default , it converts Windows EOLs to Unix, converts tabs to 4 spaces and removes trailing whitespace

**simple_benchmarker ( Bash ):** benchmark.sh executes target programs and calculates statistics. You can run benchmark.sh on Windows by using GitBash. GitBash is a Mingw based Bash console for Windows : https://git-for-windows.github.io/

**cheatsheets :** GDB ,  Windbg , Linux commands, Windows batch files , regular expressions