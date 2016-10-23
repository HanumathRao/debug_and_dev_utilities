#!/usr/bin/python
import sys
import signal
from sys import platform as _platform
import threading
import socket
import SocketServer
import time

def displayUsage():
    Utility.writeInfoMessage('usage : python tcp_server.py <port_number>')

class ConsoleColorCodes:
    RED = '\033[91m'
    BLUE = '\033[94m'
    YELLOW = '\033[93m'
    END = '\033[0m'

class Utility:     
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
                
def signal_handler(signal, frame):
        Utility.writeInfoMessage('You pressed Ctrl+C!')
        sys.exit(0)
        
class ServerHandler(SocketServer.BaseRequestHandler):
    def handle(self):
        while True:
        # self.request is the client connection
            data = self.request.recv(1024)
            if data:
                if data == 'quit':
                    self.request.close()
                else:
                    Utility.writeInfoMessage('Received : ' + data)

class Server(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
    # Ctrl-C will cleanly kill all spawned threads
    daemon_threads = True
    # much faster rebinding
    allow_reuse_address = True

    def __init__(self, server_address, RequestHandlerClass):
        SocketServer.TCPServer.__init__(self, server_address, RequestHandlerClass)
        
    def start(self):
        # Activate the server; this will keep running until you
        # interrupt the program with Ctrl-C
        self.serve_forever()

def main():
    try:
        if len(sys.argv) != 2 :
            displayUsage()
            exit(-1)
        port_number = int(sys.argv[1])
        signal.signal(signal.SIGINT, signal_handler)
        Utility.writeMessage('Server starting on port : ' + str(port_number))
        server = Server(('localhost', port_number), ServerHandler)
        server.start()
        while True:
            time.sleep(1)
    except ValueError as err:
        Utility.writeErrorMessage(err.args)

#Entry point
if __name__ == "__main__":
   main()