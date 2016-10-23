#!/usr/bin/python
import sys
import os
import os.path
from sys import platform as _platform
#As Cpython ( default python engine) uses GIL ( https://wiki.python.org/moin/GlobalInterpreterLock )
#using process instead to benefit from multicore : http://stackoverflow.com/questions/1182315/python-multicore-processing
from multiprocessing import Process, Queue
import time
#Sticking with Python 2.7 as it is default in most distros
import urllib2

class ConsoleColorCodes:
    RED = '\033[91m'
    BLUE = '\033[94m'
    YELLOW = '\033[93m'
    END = '\033[0m'

class Utility:
    @staticmethod
    def getCurrentTimeInMilliseconds():
        return int(round(time.time() * 1000))
        
    @staticmethod
    def pressAnyKey():
        if _platform == "linux" or _platform == "linux2":
            os.system('read -s -n 1 -p "Press any key to continue..."')
        elif _platform == "win32":
            os.system('pause')
            
    @staticmethod
    def askQuestionToUser(questionText, defaultAnswer):
        answer = raw_input(questionText)
        if not answer :
            answer = defaultAnswer
        return answer
        
    @staticmethod
    def writeColorMessage(message, colorCode):
        if _platform == "linux" or _platform == "linux2":
            print(  colorCode + message + ConsoleColorCodes.END )
        elif _platform == "win32":
            print(message)
        
    @staticmethod
    def writeMessage(message):
        Utility.writeColorMessage(message, ConsoleColorCodes.BLUE)
        
    @staticmethod
    def writeErrorMessage(message):
        Utility.writeColorMessage(message, ConsoleColorCodes.RED)
        
    @staticmethod
    def writeInfoMessage(message):
        Utility.writeColorMessage(message, ConsoleColorCodes.YELLOW)

class StopWatch:
    def __init__(self):
        self.startTime = 0
        self.endTime = 0
        
    def start(self):
        self.startTime = Utility.getCurrentTimeInMilliseconds()
        
    def stop(self):
        self.endTime = Utility.getCurrentTimeInMilliseconds()
        
    def elapsedTimeInMilliseconds(self):
        return self.endTime - self.startTime
        
class Query:
    def __init__(self, symbol, ask, bid):
        self.symbol = symbol
        self.ask = ask
        self.bid = bid
        self.timeElapsedInMilliseconds = 0
    
    def setTimeElapsedInMilliseconds(self, time):
        self.timeElapsedInMilliseconds = time

    def getTimeElapsedInMilliseconds(self):
        return self.timeElapsedInMilliseconds

    def getSymbol(self):
        return self.symbol

    def getAsk(self):
        return self.ask

    def getBid(self):
        return self.bid

    def toString(self):
        return self.symbol + ' : ' + str(self.ask) + ' ' + str(self.bid) + ' in ' + str(self.timeElapsedInMilliseconds) + ' milliseconds'
        
#querySymbol has to be a global method , because of Windows limitations
#in standard multiprocessing library :
#http://stackoverflow.com/questions/9670926/multiprocessing-on-windows-breaks
#It could be a method of Engine class for only Linux systems
def querySymbol(symbol, symbolUrl, targetQueue):
    queryStopWatch = StopWatch()
    queryStopWatch.start()
    ################################################################
    #Actual query part
    response = urllib2.urlopen(symbolUrl).read()
    splitResponse = response.split(',')
    query = Query(symbol, splitResponse[0], splitResponse[1])
    ##################################################################
    queryStopWatch.stop()
    query.setTimeElapsedInMilliseconds( queryStopWatch.elapsedTimeInMilliseconds() )
    targetQueue.put(query)

class Engine:
    def __init__(self):
        self.baseUrl = 'http://finance.yahoo.com/d/quotes.csv?' 
        self.functionUrl='f=ab'
        self.symbols = []
        self.processes = []
        self.stopWatch = StopWatch()
        self.sharedConcurrentResultQueue = Queue()
        self.results = []
        
    def __del__(self):
        self.shutdown()
    
    def getSymbolsFromSymbolFile(self, symbolFileName):
        symbols = []
        if not os.path.isfile(symbolFileName):
            raise ValueError(symbolFileName + ' does not exist')
        with open(symbolFileName) as fp:
            for line in fp:
                if line[0] != '#':
                    line = line.strip()
                    symbols.append(line)
        return symbols

    def loadSymbols(self, symbolFileName):
        self.symbols = self.getSymbolsFromSymbolFile(symbolFileName)

    def getSymbolUrl(self, symbol):
        url = self.baseUrl
        url += 's=' + symbol
        url += '&' + self.functionUrl
        return url

    def execute(self):
        self.stopWatch.start()
        for symbol in self.symbols:    
            currentProcess = Process(target=querySymbol, args=[symbol, self.getSymbolUrl(symbol), self.sharedConcurrentResultQueue])
            self.processes.append( currentProcess )
            self.processes[ len(self.processes) -1 ].start()

    def join(self):
        for process in self.processes:
            process.join()
        self.stopWatch.stop()
        for symbol in self.symbols:
            self.results.append( self.sharedConcurrentResultQueue.get() )
        return self.results

    def getElapsedTimeInMilliseconds(self):
        return self.stopWatch.elapsedTimeInMilliseconds()
        
    def shutdown(self):
        for process in self.processes:
            if process.is_alive():
                process.join()
    
def main():
    try:
        #Load symbols
        symbolFile = Utility.askQuestionToUser('Please enter symbol file ( Press enter for symbols.txt ) :', './symbols.txt')
        engine = Engine()
        engine.loadSymbols(symbolFile)
        #Execute queries
        engine.execute()
        results = engine.join()
        #Display results
        Utility.writeInfoMessage('Entire execution took ' + str(engine.getElapsedTimeInMilliseconds()) + ' milliseconds' )
        Utility.writeMessage('------------------------------------------------------------------------------------')
        for result in results:
            Utility.writeInfoMessage(result.toString())
        Utility.writeMessage('------------------------------------------------------------------------------------')
        Utility.pressAnyKey()
    except ValueError as err:
        Utility.writeErrorMessage(err.args)

#Entry point
if __name__ == "__main__":
   main()