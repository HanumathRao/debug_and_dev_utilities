memdump.py is a GDB extension written in Python. It dumps all memory operations done by GNU LibC Runtime ( malloc, realloc, calloc and free),
with their information ( arguments, callstacks and return value) by automating GDB. Memleak.py detects memory leaks analyzing output
of memdump.py. You can use memleak.sh to detect memory leaks at one go as it calls both memdump.py and memleak.py.

**How it works :** Recent GDBs shipped with an embedded Python interpreter. They also provide a Python API. This GDB extension
automates GDB engine to collect information about main memory functions from GNU LibC runtime.

Detailed blog article : https://nativecoding.wordpress.com/2016/07/31/gdb-debugging-automation-with-python/

For GDB Python API , see https://sourceware.org/gdb/onlinedocs/gdb/Python-API.html

For GNU LibC Runtime memory functions , see https://sourceware.org/git/?p=glibc.git;a=blob;f=malloc/malloc.c;h=1f5f166ea2ecdf601546b4157e3a291dd5c330a4;hb=HEAD

**How to run :** Provided a bash script which runs GDB in batch mode , therefore you just need :

				chmod +x ./memleak.sh 
				./memleak.sh ./debugee
				
At the end it will output a file called leak_report.txt and another one called memdump.txt.

**Watch Asciinema recording :** 



<a href="https://asciinema.org/a/8omw4c7xpqmp7sv6yud4d1kih" target="_blank"><img src="https://asciinema.org/a/1t658f4gnp6gi2fswoft42bmn.png" width="589"/></a>
										
**Sample debugee:** A sample and simple multihthreaded debugee is provided under debugee directory including its prebuilt binary. If you want to rebuild it :

				g++  -Wall -g -pthread debugee.cpp -o debugee

**Example memdump.py output :**

				type : malloc , arg1  : 256, address : 0x602010,
				callstack : 
					__GI___libc_malloc
					main
				type : realloc , arg1 : 0x602010, arg2 : 512, address : 0x602010,
				callstack : 
					__GI___libc_realloc
					main
				type : calloc , arg1 : 18, arg2 : 16, address : 0x602230,
				callstack : 
					__libc_calloc
					allocate_dtv
					__GI__dl_allocate_tls
					allocate_stack
					__pthread_create_2_1
					main
				type : calloc , arg1 : 18, arg2 : 16, address : 0x602360,
				callstack : 
					__libc_calloc
					allocate_dtv
					__GI__dl_allocate_tls
					allocate_stack
					__pthread_create_2_1
					main
				type : free , arg1 : 0x0,
				callstack : 
					__GI___libc_free
					__libc_thread_freeres
					start_thread
					clone
				type : free , arg1 : 0x0,
				callstack : 
					__GI___libc_free
					__libc_thread_freeres
					start_thread
					clone
				type : free , arg1 : 0x602010,
				callstack : 
					__GI___libc_free
					main