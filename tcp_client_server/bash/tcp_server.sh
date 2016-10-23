#!/bin/bash
#
# Bash TCP server
#
# Public Domain
#
# Akin Ocal , 2014
#
SERVER_PORT=""
trap ctrl_c INT

function ctrl_c()
{
	echo
	stop_tcp_server
	exit 0
}

function stop_tcp_server()
{	
	if [[ -f temp_file ]]
	then
		sudo rm temp_file
	fi
	
	sudo ps -ef|grep "nc -l -p"
	local process_alive=$?
	if [[ $process_alive == 0 ]]
	then
		echo killing server process
		sudo ps aux | grep -i "nc -l -p $SERVER_PORT" | awk {'print $2'} | xargs kill -9
	fi
	
	echo ""
	echo "TCP Server stopped."
	echo ""
	
	is_exiting=1
}

is_exiting=0
echo "TCP server is starting on port $1. Press Ctrl-C to quit... "
echo ""
echo ""

while [[ $is_exiting == 0 ]]
do	
	# Why do we need netcat utility as explained in http://unix.stackexchange.com/questions/49936/dev-tcp-listen-instead-of-nc-listen/49947#49947
	# Unfortunately it's impossible to do with just bash. /dev/tcp/<ip>/<port> virtual files are implemented 
	# in the way that bash tries to connect to the specified <ip>:<port> using connect(2) function. 
	# In order to create listening socket, it would have to call bind(2) function.
	nc -l -p $1
done