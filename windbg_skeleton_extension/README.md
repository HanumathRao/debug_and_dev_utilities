Here is minimum skeleton code to build an extension for Windbg. In order to use an extension, you
can deploy it to ext directory under Windbg directory ( x86 and x64 separately) and then use .load command to load your extension :

	.load skeletal_extension

And eventually call the exposed command :

	!extension_command