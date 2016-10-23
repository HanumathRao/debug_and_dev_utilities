#!/usr/bin/env python
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import SocketServer
from sys import argv

file_content=""

class HttpFileServer(BaseHTTPRequestHandler):
    def output_message(self, message):
        print(message)
        
    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_GET(self):
        global file_content
        self.output_message("HTTP GET RECEIVED")
        self._set_headers()
        self.wfile.write(file_content)

    def do_HEAD(self):
        self._set_headers()

    def do_POST(self):
        # Doesn't do anything with posted data
        #global file_content
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        self.output_message("HTTP POST RECEIVED : " + post_data)
        self._set_headers()
        self.wfile.write(file_content)

def load_file_content(file):
    global file_content
    f = open(file, 'r')
    while True:
        ch = f.read(1)
        if not ch: break
        file_content += ch

def serve(file, port):
    load_file_content(file);
    server_address = ('', port)
    httpd = HTTPServer(server_address, HttpFileServer)
    httpd.serve_forever()

if __name__ == "__main__":
    if len(argv) != 3:
        print("You have to pass a port address and file name to serve");
        exit();
    serve(argv[1], int(argv[2]))