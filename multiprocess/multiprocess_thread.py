#!/usr/bin/python
import sys
import os
import os.path
from sys import platform as _platform
from multiprocessing import Process, Queue
import time

SLAVES = ['SLAVE1', 'SLAVE2', 'SLAVE3', 'SLAVE4']

class Utility:
    @staticmethod
    def setWorkingDirectory():
        os.chdir(os.path.dirname(os.path.realpath(__file__)))

    @staticmethod
    def getCurrentTimeInMilliseconds():
        return int(round(time.time() * 1000))
        
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
        
def slaveTask(message):
    os.system("echo " + message)

class MultiprocessExecutor:
    def __init__(self, slaves):
        self.processes = []
        self.stopWatch = StopWatch()
        self.slaves = slaves

    def __del__(self):
        self.shutdown()

    def execute(self):
        self.stopWatch.start()
        i=0
        for slave in self.slaves:    
            i= i+1
            i_string = str(i)
            currentProcess = Process(target=slaveTask, args=[i_string])
            self.processes.append( currentProcess )
            self.processes[ len(self.processes) -1 ].start()

    def join(self):
        for process in self.processes:
            process.join()
        self.stopWatch.stop()

    def getElapsedTimeInMilliseconds(self):
        return self.stopWatch.elapsedTimeInMilliseconds()
        
    def shutdown(self):
        for process in self.processes:
            if process.is_alive():
                process.join()
        print("MultiprocessExecutor ending...")
    
def main():
    try:
        global SLAVES
        Utility.setWorkingDirectory()
        print("Starting...")

        multiprocess_executor = MultiprocessExecutor(SLAVES)
        multiprocess_executor.execute()
        multiprocess_executor.join()

        print('Entire execution took ' + str(multiprocess_executor.getElapsedTimeInMilliseconds()) + ' milliseconds')

    except ValueError as err:
        print(err.args)

#Entry point
if __name__ == "__main__":
   main()