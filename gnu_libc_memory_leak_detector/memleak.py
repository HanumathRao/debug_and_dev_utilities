#!/usr/bin/python
import sys
import os

class Utility:
    @staticmethod
    def getLineCount(fileName):
        ret = len(open(fileName).readlines())
        return ret

    @staticmethod
    def writeTextToFile(text, filename):
        with open(str(filename), 'w') as outputFile:
            outputFile.write(str(text))

class MemoryOperation:
    MEM_OPERATION_MALLOC = 1
    MEM_OPERATION_CALLOC = 2
    MEM_OPERATION_REALLOC = 3
    MEM_OPERATION_FREE = 4
    IGNORE_LIST = ["__pthread_create_2_1", "__libc_thread_freeres"]

    @staticmethod
    def getOperationTypeFromString(operation):
        lower_case_operation = operation.lower()
        if "malloc" in lower_case_operation:
            return  MemoryOperation.MEM_OPERATION_MALLOC
        if "calloc" in lower_case_operation:
            return  MemoryOperation.MEM_OPERATION_CALLOC
        if "realloc" in lower_case_operation:
            return  MemoryOperation.MEM_OPERATION_REALLOC
        if "free" in lower_case_operation:
            return  MemoryOperation.MEM_OPERATION_FREE
        raise ValueError('Invalid memory operation : ' + lower_case_operation)

    def __init__(self):
        self.type = MemoryOperation.MEM_OPERATION_MALLOC
        self.arg1 = ""
        self.arg2 = ""
        self.retval = ""
        self.callstack = []

    def getType(self):
        return self.type

    def setType(self, type):
        self.type = type

    def getArg1(self):
        return self.arg1

    def setArg1(self, arg1):
        self.arg1 = arg1

    def getArg2(self):
        return self.arg2

    def setArg2(self, arg2):
        self.arg2 = arg2

    def getRetval(self):
        return self.retval

    def setRetval(self, retval):
        self.retval = retval

    def getCallstack(self):
        return self.callstack

    def addToCallstack(self, frame):
        self.callstack.append(frame)

    def doesCallstackContain(self, searchString):
        for frame in self.callstack:
            if searchString in frame:
                return True
        return False

    def ignored(self):
        for ignored_function in MemoryOperation.IGNORE_LIST:
            if self.doesCallstackContain(ignored_function) == True:
                return True
        return False

    def getSize(self):
        if self.type == MemoryOperation.MEM_OPERATION_MALLOC:
            return int(self.arg1)
        if self.type == MemoryOperation.MEM_OPERATION_REALLOC:
            return int(self.arg2)
        if self.type == MemoryOperation.MEM_OPERATION_FREE:
            return -1
        if self.type == MemoryOperation.MEM_OPERATION_CALLOC:
            return int(self.arg1) * int(self.arg2)
        raise ValueError('Invalid memory operation code : ' + str(self.type))

class MemoryLeakDetector:
    def __init__(self):
        self.leakDictionary = dict()
        self.memoryOperations = []

    def addMemoryOperation(self, operation):
        if operation.ignored() == False:
            self.memoryOperations.append(operation)

    def parseFile(self, fileName):
        if not os.path.isfile(fileName):
            raise ValueError(fileName + ' does not exist')
        self.memoryOperations = []
        currentMemoryOperation = MemoryOperation()
        firstMemoryOperation = True
        gettingCallstack = False
        lineCount=0
        numberOfLines = Utility.getLineCount(fileName)
        with open(fileName) as fp:
            for line in fp:
                lineCount = lineCount+1
                line = line.strip()
                if len(line) == 0:
                    continue
                if line.startswith("type"):
                    gettingCallstack = False
                    #New memory operation ,so if not the first one
                    #then append to list
                    if firstMemoryOperation == False:
                        self.addMemoryOperation(currentMemoryOperation)
                        currentMemoryOperation = MemoryOperation()
                    firstMemoryOperation = False
                    currentLineParts = line.split(',')
                    #Find out memory operation type
                    currentLineTypeParts = currentLineParts[0].split(':')
                    currentMemoryOperation.setType( MemoryOperation.getOperationTypeFromString(currentLineTypeParts[1]))
                    # Find out memory operation arg1
                    currentLineArg1Parts = currentLineParts[1].split(':')
                    currentMemoryOperation.setArg1(currentLineArg1Parts[1])
                    #Find out memory operation arg2 and address
                    if currentMemoryOperation.getType() == MemoryOperation.MEM_OPERATION_FREE :
                        continue
                    if len(currentLineParts) == 4:
                        currentLineAddressParts = currentLineParts[2].split(':')
                        currentMemoryOperation.setRetval(currentLineAddressParts[1])
                    else:
                        currentLineArg2Parts = currentLineParts[2].split(':')
                        currentMemoryOperation.setArg2(currentLineArg2Parts[1])
                        currentLineAddressParts = currentLineParts[3].split(':')
                        currentMemoryOperation.setRetval(currentLineAddressParts[1])
                if line.startswith("callstack"):
                    gettingCallstack = True
                    continue
                if gettingCallstack == True:
                    currentMemoryOperation.addToCallstack(line)
                    if lineCount == numberOfLines:
                        #We need to add the last operation
                        self.addMemoryOperation(currentMemoryOperation)

    def analyse(self):
        operationIndex = 0
        for operation in self.memoryOperations:
            if operation.getType() == MemoryOperation.MEM_OPERATION_FREE:
                #If it is a free remove address from the dictionary
                currentAddress = operation.getArg1()
                if currentAddress in self.leakDictionary:
                    del self.leakDictionary[currentAddress]
            else:
                currentAddress = operation.getRetval()
                if operation.getType() == MemoryOperation.MEM_OPERATION_REALLOC:
                    #If it is realloc , remove old address from the dictionary first
                    currentOldAddress = operation.getArg1()
                    del self.leakDictionary[currentOldAddress]
                    #Realloc/calloc/malloc , add new address to the dictionary
                self.leakDictionary[currentAddress] = operationIndex
            operationIndex = operationIndex + 1

    def dumpLeaks(self, filename):
        output = ""
        for key in self.leakDictionary:
            leak_operation_index = self.leakDictionary[key]
            current_operation = self.memoryOperations[leak_operation_index]
            output = output + "----------------------------------------------------------" + "\n"
            output = output + "Leak size : " + str(current_operation.getSize()) + "\n"
            output = output + "Callstack : " + "\n"
            current_callstack = current_operation.getCallstack()
            for frame in current_callstack:
                output = output + "\t" + frame + "\n"
        if len(output) == 0:
            output = output + "\n" + "NO MEMORY LEAKS" + "\n"
        else:
            output = output + "----------------------------------------------------------"
        Utility.writeTextToFile(output, filename)
        
def main():
    try:
        #Get arguments
        memdumpOutput = sys.argv[1]
        leakReport = sys.argv[2]
        #Start leak detection
        leakDetector = MemoryLeakDetector()
        leakDetector.parseFile(memdumpOutput)
        leakDetector.analyse()
        #Dump leak report
        leakDetector.dumpLeaks(leakReport)
    except ValueError as err:
        print(err.args)

#Entry point
if __name__ == "__main__":
   main()
