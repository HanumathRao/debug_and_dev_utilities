Licence : All samples are "Public Domain" code 
http://en.wikipedia.org/wiki/Public_domain_software

===========================================================================

In this repository I will collect various debugging automation and tracing scripts and also various 
cheatsheets.

**memory_leak_detector ( Python / GDB Automation):** memdump.py is a GDB extension written in Python. It dumps all memory operations done by GNU LibC Runtime ( malloc, realloc, calloc and free),
with their information ( arguments, callstacks and return value) by automating GDB. Memleak.py detects memory leaks analyzing output
of memdump.py. You can use memleak.sh to detect memory leaks at one go as it calls both memdump.py and memleak.py.

Detailed blog article : https://nativecoding.wordpress.com/2016/07/31/gdb-debugging-automation-with-python/

**gdb_cheatsheet :** GDB cheatsheet including GDB automation , coredumps, text UI mode and hw watchpoints

**windbg_cheatsheet :** Windbg cheatsheet

Some C++ utilities : 

- As for programatic examples such as inserting memory/hardware breakpoints and hooking GNU LibC/MS CRT memory functions
see https://github.com/akhin/cpp_multithreaded_order_matching_engine/tree/master/source/memory/debugging

- a header only C++ mini library that allows you to throw exception messages with file, line number, function name
, callstack and also supports colored console messages and even traces for syslog/Dbgview. Supports GCC/Linux and MSVC/Windows.
 : https://nativecoding.wordpress.com/2016/07/24/c-pretty-exceptions/