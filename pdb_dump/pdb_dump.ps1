<#
        Action can be one of below

        Get-Pdb-Items
        Resolve-Address
        Dump-Pdb-To-CSV
#>
param([string]$PORTABLE_EXECUTABLE_NAME="", [string]$ACTION = "", [string]$HEX_ADDRESS="", [string]$CSV_FILE="")

function compile_csharp_code()
{
  $source = @"
            using System;
            using System.Runtime.InteropServices;
            using System.Collections.Generic;
            
    public class PdbDump
    {
        [Flags]
        private enum SymOpt : uint
        {
            CASE_INSENSITIVE = 0x00000001,
            UNDNAME = 0x00000002,
            DEFERRED_LOADS = 0x00000004,
            NO_CPP = 0x00000008,
            LOAD_LINES = 0x00000010,
            OMAP_FIND_NEAREST = 0x00000020,
            LOAD_ANYTHING = 0x00000040,
            IGNORE_CVREC = 0x00000080,
            NO_UNQUALIFIED_LOADS = 0x00000100,
            FAIL_CRITICAL_ERRORS = 0x00000200,
            EXACT_SYMBOLS = 0x00000400,
            ALLOW_ABSOLUTE_SYMBOLS = 0x00000800,
            IGNORE_NT_SYMPATH = 0x00001000,
            INCLUDE_32BIT_MODULES = 0x00002000,
            PUBLICS_ONLY = 0x00004000,
            NO_PUBLICS = 0x00008000,
            AUTO_PUBLICS = 0x00010000,
            NO_IMAGE_SEARCH = 0x00020000,
            SECURE = 0x00040000,
            SYMOPT_DEBUG = 0x80000000
        };

        [Flags]
        private enum SymFlag : uint
        {
            VALUEPRESENT = 0x00000001,
            REGISTER = 0x00000008,
            REGREL = 0x00000010,
            FRAMEREL = 0x00000020,
            PARAMETER = 0x00000040,
            LOCAL = 0x00000080,
            CONSTANT = 0x00000100,
            EXPORT = 0x00000200,
            FORWARDER = 0x00000400,
            FUNCTION = 0x00000800,
            VIRTUAL = 0x00001000,
            THUNK = 0x00002000,
            TLSREL = 0x00004000,
        }

        [Flags]
        private enum SymTagEnum : uint
        {
            Null,
            Exe,
            Compiland,
            CompilandDetails,
            CompilandEnv,
            Function,
            Block,
            Data,
            Annotation,
            Label,
            PublicSymbol,
            UDT,
            Enum,
            FunctionType,
            PointerType,
            ArrayType,
            BaseType,
            Typedef,
            BaseClass,
            Friend,
            FunctionArgType,
            FuncDebugStart,
            FuncDebugEnd,
            UsingNamespace,
            VTableShape,
            VTable,
            Custom,
            Thunk,
            CustomType,
            ManagedType,
            Dimension
        };

        [StructLayout(LayoutKind.Sequential)]
        private struct SYMBOL_INFO
        {
            public uint SizeOfStruct;
            public uint TypeIndex;
            public ulong Reserved1;
            public ulong Reserved2;
            public uint Reserved3;
            public uint Size;
            public ulong ModBase;
            public SymFlag Flags;
            public ulong Value;
            public ulong Address;
            public uint Register;
            public uint Scope;
            public SymTagEnum Tag;
            public int NameLen;
            public int MaxNameLen;

            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 1024)]
            public string Name;
        };

        [DllImport("dbghelp.dll", SetLastError = true)]
        private static extern bool SymInitialize(IntPtr hProcess, string UserSearchPath, bool fInvadeProcess);

        [DllImport("dbghelp.dll", SetLastError = true)]
        private static extern uint SymSetOptions(uint SymOptions);

        [DllImport("dbghelp.dll", SetLastError = true)]
        private static extern uint SymGetOptions();

        [DllImport("dbghelp.dll", SetLastError = true)]
        private static extern ulong SymLoadModule64(IntPtr hProcess, IntPtr hFile,
            string ImageName, string ModuleName,
            ulong BaseOfDll, uint SizeOfDll);

        [DllImport("dbghelp.dll", SetLastError = true)]
        private static extern bool SymFromAddr(IntPtr hProcess,
            ulong dwAddr, out ulong pdwDisplacement, ref SYMBOL_INFO symbolInfo);

        [DllImport("dbghelp.dll", SetLastError = true)]
        private static extern bool SymUnloadModule64(IntPtr hProcess, ulong BaseOfDll);

        [DllImport("dbghelp.dll", SetLastError = true)]
        private static extern bool SymCleanup(IntPtr hProcess);

        private const int MAX_SYM_NAME = 2000;

        private static ulong convertHexAddressToUlong(string address)
        {
            ulong ret = 0;
            ret = Convert.ToUInt64(address, 16);
            return ret;
        }

        private static string convertAddressToHexString(ulong address)
        {
            string ret = "";
            string hexOutput = String.Format("{0:X}", address);
            ret = "0x" + hexOutput;
            return ret;
        }

        public static string getMethodNameFromAddress(string portableExecutableName, string address)
        {
            if(System.IO.File.Exists(portableExecutableName) == false)
            {
                throw new Exception("PE file can not be found");
            }

            var foundMethodName = "";

            var currentProcess = System.Diagnostics.Process.GetCurrentProcess().Handle;
            var addressUlong = convertHexAddressToUlong(address);

            var options = SymGetOptions();
            options |= (uint)(SymOpt.SYMOPT_DEBUG | SymOpt.LOAD_LINES);

            SymSetOptions(options);

            var ret = SymInitialize(currentProcess, null, false);

            if (ret == false)
            {
                throw new Exception("Could not initialise Dbghelp");
            }

            var moduleBaseAddress = SymLoadModule64(currentProcess, System.IntPtr.Zero, portableExecutableName, "", 0, 0);

            if (moduleBaseAddress == 0)
            {
                throw new Exception("SymLoadModule64 failed");
            }
            
            ulong displacement = 0;
            int bufferSize = Marshal.SizeOf(typeof(SYMBOL_INFO)) + ((MAX_SYM_NAME - 2) * 2);
            
            SYMBOL_INFO symbolInfo = new SYMBOL_INFO();

            symbolInfo.SizeOfStruct = (uint)Marshal.SizeOf(typeof(SYMBOL_INFO)) - 1024;
            symbolInfo.MaxNameLen = 1024;

            ret = SymFromAddr(currentProcess, addressUlong, out displacement, ref symbolInfo);

            if (ret == false)
            {
                SymUnloadModule64(currentProcess, moduleBaseAddress);
                SymCleanup(currentProcess);
                throw new Exception(string.Format("Could not resolve address {0} of {1} file, error code : {2}", address, portableExecutableName, Marshal.GetLastWin32Error() ));
            }

            foundMethodName = symbolInfo.Name;

            SymUnloadModule64(currentProcess, moduleBaseAddress);
            SymCleanup(currentProcess);

            return foundMethodName;
        }

        public class PdbItem
        {
            public string ItemName { get; set; }
            public string Tag { get; set; }
            public string Flag { get; set; }
            public string Address { get; set; }
            public string Value { get; set; }
            public string Module { get; set; }
        }

        private delegate bool SymEnumSymbolsProc(ref SYMBOL_INFO pSymInfo, uint SymbolSize, IntPtr UserContext);

        [DllImport("dbghelp.dll", SetLastError = true)]
        private static extern bool SymEnumSymbols(IntPtr hProcess, ulong BaseOfDll, string Mask, SymEnumSymbolsProc EnumSymbolsCallback, IntPtr UserContext);

        private delegate bool SymEnumerateModules64Proc(string moduleName, ulong BaseOfDll, IntPtr UserContext);

        [DllImport("dbghelp.dll", SetLastError = true)]
        private static extern bool SymEnumerateModules64(IntPtr hProcess, SymEnumerateModules64Proc EnumModules64Callback, IntPtr UserContext);

        private static List<PdbItem> _pdbItems;
        private static Dictionary<string, string> _moduleAddressTable;

        private static bool enumerateSymbols(ref SYMBOL_INFO pSymInfo, uint SymbolSize, IntPtr UserContext)
        {
            PdbItem currentItem = new PdbItem();
            currentItem.ItemName = pSymInfo.Name;
            currentItem.Address = convertAddressToHexString(pSymInfo.Address);
            currentItem.Tag = pSymInfo.Tag.ToString();
            currentItem.Flag = pSymInfo.Flags.ToString();
            currentItem.Value = pSymInfo.Value.ToString();

            string currentModuleBaseAddress = convertAddressToHexString(pSymInfo.ModBase);
            if( _moduleAddressTable.ContainsKey(currentModuleBaseAddress))
            {
                currentItem.Module = _moduleAddressTable[currentModuleBaseAddress];
            }
            else
            {
                currentItem.Module = currentModuleBaseAddress;
            }
            
            _pdbItems.Add(currentItem);
            return true;
        }

        private static bool enumerateModules(string moduleName, ulong baseAddress, IntPtr UserContext)
        {
            _moduleAddressTable.Add(convertAddressToHexString(baseAddress), moduleName);
            return true;
        }

        static private void buildModuleAddressTable(IntPtr proc)
        {
            _moduleAddressTable = new Dictionary<string, string>();

            if( PdbDump.SymEnumerateModules64(proc, enumerateModules, System.IntPtr.Zero) == false )
            {
                throw new Exception(string.Format("Could not enumarate modules : {0}", Marshal.GetLastWin32Error() ));
            }
        }

        static public void dumpSymbolsAsCSV(string portableExeuctableName, string csvOutput)
        {
            List<PdbItem> items = getAllItems(portableExeuctableName);

            if (System.IO.File.Exists(csvOutput))
            {
                System.IO.File.Delete(csvOutput);
            }

            System.Text.StringBuilder builder = new System.Text.StringBuilder();

            foreach(PdbItem item in items)
            {
                builder.Append(string.Format("{0},{1},{2},{3},{4},{5}", item.ItemName, item.Tag, item.Module, item.Address, item.Value, item.Flag));
                builder.Append(System.Environment.NewLine);
            }

            System.IO.StreamWriter file = new System.IO.StreamWriter(csvOutput);
            file.Write(builder.ToString());
            file.Close();
        }

        static public List<PdbItem> getAllItems(string portableExecutableName)
        {
            if(System.IO.File.Exists(portableExecutableName) == false)
            {
                throw new Exception("PE file can not be found");
            }

            var currentProcess = System.Diagnostics.Process.GetCurrentProcess().Handle;

            var options = SymGetOptions();
            options |= (uint)(SymOpt.SYMOPT_DEBUG | SymOpt.INCLUDE_32BIT_MODULES);

            SymSetOptions(options);

            var ret = SymInitialize(currentProcess, null, false);

            if (ret == false)
            {
                throw new Exception("Could not initialise Dbghelp");
            }
            
            var moduleBaseAddress = SymLoadModule64(currentProcess, System.IntPtr.Zero, portableExecutableName, "", 0, 0);
           
            if (moduleBaseAddress == 0)
            {
                throw new Exception("SymLoadModule64 failed");
            }

            buildModuleAddressTable(currentProcess);

            _pdbItems = new List<PdbItem>();
            PdbDump.SymEnumSymbols(currentProcess, moduleBaseAddress, "*", enumerateSymbols, System.IntPtr.Zero);

            SymUnloadModule64(currentProcess, moduleBaseAddress);
            SymCleanup(currentProcess);

            return _pdbItems;
        }
    }
"@
    try
    {
	    Add-Type -TypeDefinition $source;
    }
    catch {}
}

Clear-Host
compile_csharp_code

try
{
    [string]$lowercase_action = $ACTION.ToLower()

    if( $lowercase_action -eq "resolve-address" )
    {
        Write-Host ( [PdbDump]::getMethodNameFromAddress($PORTABLE_EXECUTABLE_NAME, $HEX_ADDRESS) )
    }
    elseif ( $lowercase_action -eq "get-pdb-items")
    {
        return [PdbDump]::getAllItems($PORTABLE_EXECUTABLE_NAME)
    }p
    elseif( $lowercase_action -eq "dump-pdb-to-csv" )
    {
        [PdbDump]::dumpSymbolsAsCSV($PORTABLE_EXECUTABLE_NAME, $CSV_FILE)
    }
    else
    {
        throw "Invalid action specified"
    }
}
catch
{
    $e = $_.Exception
    Write-Host $e.Message
	Write-Host ""
	Write-Host "Usage to resolve address: pdb_dump.ps1 -PORTABLE_EXECUTABLE_NAME portable_executable -ACTION Resolve-Address -HEX_ADDRESS hex_address"
    Write-Host "Usage to get all PDB objects: pdb_dump.ps1 -PORTABLE_EXECUTABLE_NAME portable_executable -ACTION Get-PDB-Items"
    Write-Host "Usage to dump all pdb information to a CSV file : pdb_dump.ps1 -PORTABLE_EXECUTABLE_NAME portable_executable -ACTION Dump-PDB-To-CSV -CSV_FILE target_csv_file"
	Write-Host ""
    exit 1
}
exit 0