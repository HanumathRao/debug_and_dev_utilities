Address resolver is a tool that converts function addresses in a given portable executable to function names. The tool requires PDB file.

UI Tool : 

<img src="https://github.com/akhin/debug_and_dev_utilities/blob/master/pdb_address_resolver/images/address_resolver_ui.png" align="center">

Script version : You can also use it in command line as below :

	address_resolver.bat portable_executable hex_address
	
Troubleshooting : If an address can not be found , you will receive an error message with error code 126. In order to troubleshoot it ,
you can use Microsoft`s Dbgview utility when reproducing the issue . You can troubleshoot by looking at debug traces as below :

<img src="https://github.com/akhin/debug_and_dev_utilities/blob/master/pdb_address_resolver/images/address_resolver_troubleshooting.png" align="center">
