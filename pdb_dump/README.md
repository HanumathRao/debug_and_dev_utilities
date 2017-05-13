PDB dump is a tool that receives a portable executable as input and it can do one followings :

1. Resolving name of a function using hex address

		pdb_dump.ps1 -PORTABLE_EXECUTABLE_NAME portable_executable -ACTION Resolve-Address -HEX_ADDRESS hex_address

2. Dump all pdb items as CSV ( Repo contains doom3.csv as an example output built from Doom3`s debug mode executable )

		pdb_dump.ps1 -PORTABLE_EXECUTABLE_NAME portable_executable -ACTION Get-PDB-Items

3. Get all PDB items as an object array in Powershell command prompt :

	$items = .\pdb_dump.ps1  -PORTABLE_EXECUTABLE_NAME portable_executable -ACTION get-pdb-items
	$items 

	ItemName : __glewVertexAttrib2svNV
	Tag      : Data
	Flag     : 0
	Address  : 0x142D86D58
	Value    : 0
	Module   : RBDoom3BFG

	ItemName : idMover_Periodic::Type
	Tag      : Data
	Flag     : 0
	Address  : 0x1435951B0
	Value    : 0
	Module   : RBDoom3BFG

	ItemName : r_useCachedDynamicModels
	Tag      : Data
	Flag     : 0
	Address  : 0x142BEA9D0
	Value    : 0
	Module   : RBDoom3BFG

	...

**Troubleshooting address resolving :** If an address can not be found , you will receive an error message with error code 126. In order to troubleshoot it ,
you can use Microsoft`s Dbgview utility when reproducing the issue . You can troubleshoot by looking at debug traces as below :

<img src="https://github.com/akhin/debug_and_dev_utilities/blob/master/pdb_dump/images/pdb_dump_troubleshooting.png" align="center">
