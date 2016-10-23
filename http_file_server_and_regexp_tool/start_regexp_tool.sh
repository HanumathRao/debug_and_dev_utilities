clear
PORT=8080
URL=http://localhost:$PORT
SERVER=http_file_server.py
FILE=regexp_tool.htm
echo Web server starting at $PORT
echo
echo Browse $URL
echo
echo Ctrl C for exit
echo
python $SERVER $FILE $PORT