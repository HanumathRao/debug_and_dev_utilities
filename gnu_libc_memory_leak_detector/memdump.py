#!/usr/bin/python
#
# Akin Ocal, nativecoding.wordpress.com 
#
# Licence : All samples are "Public Domain" code 
# http://en.wikipedia.org/wiki/Public_domain_software
#
# For source code of GNU Lib C memory functions , see :
# https://sourceware.org/git/?p=glibc.git;a=blob;f=malloc/malloc.c;h=1f5f166ea2ecdf601546b4157e3a291dd5c330a4;hb=HEAD
#
try:
    import gdb
except ImportError as e:
    raise ImportError("This script must be run in GDB: ", str(e))
    
logFileName = "memdump.txt"

class ConsoleColorCodes:
    RED = '\033[91m'
    BLUE = '\033[94m'
    YELLOW = '\033[93m'
    END = '\033[0m'

class Utility:       
    @staticmethod
    def writeColorMessage(message, colorCode):
        print(  colorCode + message + ConsoleColorCodes.END )
        
    @staticmethod
    def writeMessage(message):
        Utility.writeColorMessage(message, ConsoleColorCodes.BLUE)
        
    @staticmethod
    def writeErrorMessage(message):
        Utility.writeColorMessage(message, ConsoleColorCodes.RED)
        
    @staticmethod
    def logInfoMessage(message):
        global logFileName
        with open(str(logFileName), 'a') as logFile:
            logFile.write(str(message))
        
    @staticmethod
    def writeInfoMessage(message):
        Utility.logInfoMessage(message)
        Utility.writeColorMessage(message, ConsoleColorCodes.YELLOW)
    
    @staticmethod
    def convertToHexString(input):
        output = int(input)
        output = hex(output)
        output = str(output)
        return output

class MemdumpCommand (gdb.Command):
    """Dumps memory operations : malloc, realloc, calloc and free"""

    def __init__ (self):
        super (MemdumpCommand, self).__init__ ("memdump",
                                                       gdb.COMMAND_SUPPORT,
                                                       gdb.COMPLETE_FILENAME)
        self.memoryFunctions = ["main", "exit", "__libc_malloc" , "__libc_free", "__libc_calloc", "__libc_realloc"]
        self.mallocArgs = ["bytes"]
        self.callocArgs = ["n", "elem_size"]
        self.reallocArgs = ["oldmem", "bytes"]
        self.freeArgs = ["mem"]
        self.max_callstack_depth = 16
        
    def get_callstack(self):
        ret = []
        depth = 1
        frame = gdb.selected_frame()
        while True:
            if (frame) and ( depth <= self.max_callstack_depth ):
                current_frame_name = str(frame.name())
                ret.append(current_frame_name)
                frame = frame.older()
                depth += 1
            else:
                gdb.Frame.select ( gdb.newest_frame() )
                return ret
                
    def get_return_value(self):
        ret = ""
        gdb.execute("finish")
        gdb.execute("finish")
        ret = str(gdb.parse_and_eval("$rax"))
        return ret
                
    def get_symbol(self, symbol):
        ret = ""
        frame = gdb.selected_frame()
        block = frame.block()
        for current_symbol in block: 
            if str(symbol) == current_symbol.name:
                ret = str(current_symbol.value(frame))
        return ret
        
    def append_callstack(self, target, callstack):
        ret = str(target) + "\ncallstack : "
        for callstack_frame in callstack:
            ret += "\n\t"
            ret += str(callstack_frame)
        return ret
        
    def invoke (self, arg, from_tty):
        if arg:
            self.max_callstack_depth = int(arg)
        Utility.writeMessage('MEMLEAK STARTING WITH MAX CALLSTACK DEPTH : ' + str(self.max_callstack_depth))
        gdb.execute("set confirm off")
        gdb.execute("set pagination off")
        gdb.execute("set non-stop on")
        gdb.execute("set breakpoint pending on")
        backtrace_limit_command = "set backtrace limit " + str(self.max_callstack_depth)
        gdb.execute(backtrace_limit_command)
        # Setup breakpoints for memory functions
        for memoryFunction in self.memoryFunctions:
            gdb.execute("b " + memoryFunction)
        # Start to run the debugeee
        gdb.execute("r")
        while True:
            frame = gdb.selected_frame()
            current_frame_name = str(frame.name())
            ##########################################################################
            #MAIN
            if "main" in current_frame_name:
                gdb.execute("cont")
            ##########################################################################
            #EXIT
            if "exit" in current_frame_name:
                Utility.writeInfoMessage("\n")
                break
            ##########################################################################
            #MALLOC
            if "malloc" in current_frame_name:
                message = "\ntype : malloc ,"
                gdb.execute("n")
                gdb.execute("n")
                #Initially we get bytes variable , only arg to malloc
                counter = 1
                for malloc_arg in self.mallocArgs:
                    message += " arg" + str(counter) + "  : "
                    message += self.get_symbol(malloc_arg)
                    message += ","
                    counter += 1
                #Now we get the callstack at this point
                callstack = self.get_callstack()
                # Finally we read the return value of malloc from the CPU register
                address = Utility.convertToHexString(self.get_return_value())
                message += " address : " + address
                message += ","
                # append callstack at the end
                message = self.append_callstack(message, callstack)
                # Continue
                Utility.writeInfoMessage(message)
                gdb.execute("cont")
            ##########################################################################
            #CALLOC
            if "calloc" in current_frame_name:
                message = "\ntype : calloc ,"
                gdb.execute("n")
                gdb.execute("n")
                #Get arguments to calloc
                counter = 1
                for calloc_arg in self.callocArgs:
                    message += " arg" + str(counter) + " : "
                    message += self.get_symbol(calloc_arg)
                    message += ","
                    counter += 1
                #Now we get the callstack at this point
                callstack = self.get_callstack()
                # Finally we read the return value from the CPU register
                address = Utility.convertToHexString(self.get_return_value())
                message += " address : " + address
                message += ","
                # append callstack at the end
                message = self.append_callstack(message, callstack)
                # Continue
                Utility.writeInfoMessage(message)
                gdb.execute("cont")
            ##########################################################################
            #REALLOC
            if "realloc" in current_frame_name:
                message = "\ntype : realloc ,"
                gdb.execute("n")
                gdb.execute("n")
                #Get arguments to realloc
                counter = 1
                for realloc_arg in self.reallocArgs:
                    message += " arg" + str(counter) + " : "
                    message += self.get_symbol(realloc_arg)
                    message += ","
                    counter += 1
                #Now we get the callstack at this point
                callstack = self.get_callstack()
                # Finally we read the return value from the CPU register
                address = Utility.convertToHexString(self.get_return_value())
                message += " address : " + address
                message += ","
                # append callstack at the end
                message = self.append_callstack(message, callstack)
                # Continue
                Utility.writeInfoMessage(message)
                gdb.execute("cont")
            ##########################################################################
            #FREE
            if "free" in current_frame_name:
                message = "\ntype : free ,"
                gdb.execute("n")
                gdb.execute("n")
                #Initially we get arguments to free
                counter = 1
                for free_arg in self.freeArgs:
                    message += " arg" + str(counter) + " : "
                    message += self.get_symbol(free_arg)
                    message += ","
                    counter += 1
                #Now we get the callstack at this point
                callstack = self.get_callstack()
                # append callstack at the end
                message = self.append_callstack(message, callstack)
                # Continue
                Utility.writeInfoMessage(message)
                gdb.execute("cont")
        # Remove breakpoints
        for memoryFunction in self.memoryFunctions:
            gdb.execute("clear " + memoryFunction)
        Utility.writeMessage('DEBUGEE EXITING')
        gdb.execute("cont")

MemdumpCommand ()
