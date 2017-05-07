using System;
using System.Runtime.InteropServices;

namespace address_resolver
{
    class AddressResolver
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

        public static string getMethodNameFromAddress(string binaryName, string address)
        {
            if(System.IO.File.Exists(binaryName) == false)
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

            var modBase = SymLoadModule64(currentProcess, System.IntPtr.Zero, binaryName, "", 0, 0);

            if (modBase == 0)
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
                SymUnloadModule64(currentProcess, modBase);
                SymCleanup(currentProcess);
                throw new Exception(string.Format("Could not resolve address {0} of {1} file, error code : {2}", address, binaryName, Marshal.GetLastWin32Error() ));
            }

            foundMethodName = symbolInfo.Name;

            SymUnloadModule64(currentProcess, modBase);
            SymCleanup(currentProcess);

            return foundMethodName;
        }
    }
}