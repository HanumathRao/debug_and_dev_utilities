<td><img src="https://img.shields.io/badge/LICENCE-PUBLIC%20DOMAIN-green.svg" alt="Licence badge"></td>

In this repository I will collect various utilities.

**memory_leak_detector ( Python ):** memdump.py is a GDB extension written in Python. It dumps all memory operations done by GNU LibC Runtime ( malloc, realloc, calloc and free),
with their information ( arguments, callstacks and return value) by automating GDB. Memleak.py detects memory leaks analyzing output
of memdump.py. You can use memleak.sh to detect memory leaks at one go as it calls both memdump.py and memleak.py.

Detailed blog post : https://nativecoding.wordpress.com/2016/07/31/gdb-debugging-automation-with-python/

**cpp_reflection_tool ( Python ) :** It is  simple Python script which uses Clang , in order to create a header file
with metadata of target source file.

Detailed blog post : https://nativecoding.wordpress.com/2016/10/25/c-reflection-using-clang/

**pretty_exception ( C++ ):** It is a header only library for GCC and MSVC to throw standard exceptions
with callstacks and in colour.

Detailed blog post : https://nativecoding.wordpress.com/2016/07/24/c-pretty-exceptions/

**windbg_automation_examples :** This directory has the code used in "Windbg automation and extensions" blog post :

https://nativecoding.wordpress.com/2016/01/10/automate-attach-to-process-on-windows-with-windbg/
