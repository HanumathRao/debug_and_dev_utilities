#!/bin/bash
#
# Bash TCP client
#
# Public Domain
#
# Akin Ocal , 2014
#
function send_tcp_message()
{
	local address=$1
	local port=$2
	local message=$3
	exec 3<>/dev/tcp/$address/$port
	echo -e "$message" >&3
}

send_tcp_message $1 $2 $3