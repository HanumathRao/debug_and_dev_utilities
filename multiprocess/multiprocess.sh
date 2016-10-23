#!/bin/bash
SLAVES=('SLAVE1' 'SLAVE2' 'SLAVE3' 'SLAVE4' );

function task()
{
    local slave_name=$1
	touch $slave_name
}

start=$(($(date +%s%N)/1000000))
for i in "${SLAVES[@]}"
do
    echo "Starting $i"
    task $i & EXEC_PID=$!
done

#Wait for all forked child processes
wait

finish=$(($(date +%s%N)/1000000))
current_execution_time=$(($finish-$start))
echo ""
echo "Time : $current_execution_time milliseconds "

echo "Finished , press enter key to quit."
echo ""
read