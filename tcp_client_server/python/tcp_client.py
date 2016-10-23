#!/usr/bin/python
import sys
import socket

def displayUsage():
    print('usage : python tcp_client.py <server> <port_number> <message>')
    
def send_tcp_message(server, port_number, message):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((server,port_number)) 
    s.send(message) 
    s.close()

def main():
    try:
        if len(sys.argv) != 4 :
            displayUsage()
            exit(-1)
        server = str(sys.argv[1])
        port_number = int(sys.argv[2])
        message = str(sys.argv[3])
        print('Sending message ' + message + ' to ' + server + ' , port ' + str(port_number))
        send_tcp_message(server, port_number, message)
    except ValueError as err:
        print(err.args)

#Entry point
if __name__ == "__main__":
    main()