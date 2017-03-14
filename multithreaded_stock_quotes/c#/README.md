						
**How to run C# version on Windows and Linux. :** For Windows, you can use multithreaded_stock_quotes.bat which takes advantage of .Net Frameworks that are shipped with Windows.
Alternatively you use Visual Studio solution file. For Linux systems you will need to have Mono :

				For Debian systems :
				
					sudo apt-get install mono-complete
					
				For CentOS systems :
				
					yum install yum-utils
					rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
					yum-config-manager --add-repo http://download.mono-project.com/repo/centos/
					yum install mono-devel
					
Then you can use multithreaded_stock_quotes.sh , which builds the project and runs the executable. Alternatively you can use a makefile in build directory as described in next section.
		
**How to build C# project for Linux (Mono) and Windows :** You can find it under "c#" directory.

a) Windows systems : You can use Visual Studio 2013 solution file provided. 
Tested with Visual Studio 2013 Express Edition.

	1) Open Visual Studio developer command line
	2) Change your directory to build/windows
	3) Type "msbuild MultithreadedStockQuotes.csproj" and then press enter
	
	Alternatively you can use Visual Studio

b) Linux Systems : You can build with Mono. This has been tested against Debian Wheezy and CentOS7 :
		
	To build : 
	
			1) Change your directory to build/linux
			2) Type "make" and press enter
	
				
	How to execute it : After a successful build, the executable is created under 
	root directory. After changing your directory to the executable`s location :
		
				mono multithreaded_stock_quotes.exe symbols.txt