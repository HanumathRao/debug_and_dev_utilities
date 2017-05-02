#if _WIN64
#define KDEXT_64BIT
#else
#define KDEXT_32BIT
#endif

#ifdef _WIN64
#define STACKFRAME EXTSTACKTRACE64
#else
#define STACKFRAME EXTSTACKTRACE32
#endif

#include <Windows.h>

// MSDN : https://msdn.microsoft.com/en-us/library/ff561258(v=vs.85).aspx
#include <WDBGEXTS.H>

#define NEW_LINE "\n"

// MSDN : https://msdn.microsoft.com/en-us/library/ff543968.aspx
// Version of our extension for Windbg
//
// What is 5 and 5 :
//http://www.codeproject.com/Articles/6522/Debug-Tutorial-Part-Writing-WINDBG-Extensions
EXT_API_VERSION g_ExtApiVersion = {
         5 ,
         5 ,
         EXT_API_VERSION_NUMBER ,
         0
     } ;

WINDBG_EXTENSION_APIS ExtensionApis = {0};

__declspec(dllexport) LPEXT_API_VERSION  ExtensionApiVersion(void)
{
    return &g_ExtApiVersion;
}

// MSDN : https://msdn.microsoft.com/en-us/library/ff561303.aspx
__declspec(dllexport) VOID WinDbgExtensionDllInit(
	PWINDBG_EXTENSION_APIS lpExtensionApis,
	USHORT windowsMajorVersion, 
	USHORT windowsMinorVersion)
{
    ExtensionApis = *lpExtensionApis;
	  // windowsMajorVersion and windowsMinorVersion
    // is the version of current system
}

__declspec(dllexport) DECLARE_API (extension_info)
{
    dprintf(NEW_LINE);
    dprintf(NEW_LINE);
}

__declspec(dllexport) DECLARE_API (extension_command)
{
}