#!/bin/bash
#
# Bash shell script to run benchmarks
#
#   USAGE :
#
#       ./benchmark.sh <./program_name arguments> <iteration_number>
#
#	HOW TO USE ON WINDOWS SYSTEMS
#
#		You can run benchmark.sh on Windows by using GitBash. 
#		GitBash is a Mingw based Bash console for Windows : https://git-for-windows.github.io/
#
# Public Domain
#
# Akin Ocal , 2015
#
PROGRAM_NAME=""
ITERATION_NUMBER=""
MIN_TIME=
MAX_TIME=
AVERAGE_TIME=0
FLOATING_POINT_PRECISION=5
TIME_ARRAY=
TIME_UNIT="milliseconds"

function write_message()
{
    echo $1
    echo
}

function write_info_message()
{
    echo "$(tput setaf 3)${1}$(tput sgr 0)"
}

function write_error_message()
{
    echo "$(tput setaf 1)${1}$(tput sgr 0)"
}

function display_usage()
{
    write_message "USAGE :"
    echo "  ./benchmark.sh <program_name arguments> <iteration_number>"
    echo
    write_message "EXAMPLES :"
    echo "  ./benchmark.sh ./custom_executable 10"
    echo "  ./benchmark.sh \"./custom_executable custom_arg1 custom_arg2\" 10"
    echo
}

IS_COMMAND_VALID_RESULT=0
function is_command_valid()
{
    local command_name=$1
    local which_command=`which ${command_name}`
    local valid_command=${#which_command}
    
    if [ $valid_command -eq 0 ]; then
        IS_COMMAND_VALID_RESULT=0   
        return
    fi
    IS_COMMAND_VALID_RESULT=1
}

function validate_input()
{
    local tokens=( $PROGRAM_NAME )
    local executable_name=${tokens[0]}
    
    # Check if executable exists
    if [ ! -f $executable_name ] ; then
        is_command_valid $executable_name
        if [ $IS_COMMAND_VALID_RESULT -eq 0 ]; then
            write_error_message "$executable_name is not an executable."        
            exit -2
        fi
    fi
    
    valid_number_regexp='^[0-9]+$' #Regular expression for number check
    
    if ! [[ $ITERATION_NUMBER =~ $valid_number_regexp ]] ; then
        write_error_message "$ITERATION_NUMBER is not a valid number"
        exit -3
    fi
        
    if [ "$ITERATION_NUMBER" -lt 1 ];then
        write_error_message "$ITERATION_NUMBER is not a valid iteration number : It has to be greater than zero"
        exit -4
    fi
}

function execute_benchmark()
{
    START=0
    #Execute program n times and collect execution times
    for (( c=$START; c<$ITERATION_NUMBER; c++ ))
    do
        local start=$(($(date +%s%N)/1000000))
        $PROGRAM_NAME >> /dev/null
        local finish=$(($(date +%s%N)/1000000))
        local current_execution_time=$(($finish-$start))
        TIME_ARRAY[$c]=$current_execution_time
        #echo $current_execution_time
    done
}

function calculate_results()
{
    local sum=0
    MAX_TIME=${TIME_ARRAY[0]}
    MIN_TIME=${TIME_ARRAY[0]}
    #Calculate sum, min, max
    for i in "${TIME_ARRAY[@]}"
    do
        sum=$(($sum + $i))
        
        # Update max if applicable
        if [[ "$i" -gt "$MAX_TIME" ]]; then
            MAX_TIME="$i"
        fi

        # Update min if applicable
        if [[ "$i" -lt "$MIN_TIME" ]]; then
            MIN_TIME="$i"
        fi
    done
    #As Bash doesn`t support floating points, we need help from Awk
    AVERAGE_TIME=$(awk "BEGIN {printf \"%.${FLOATING_POINT_PRECISION}f\",${sum}/${ITERATION_NUMBER}}")
}

function display_results()
{
    write_message "----------------------------------------------"
    write_info_message "Program executed : $PROGRAM_NAME"
    write_info_message "Iteration times : $ITERATION_NUMBER"
    write_info_message "Maximum time : $MAX_TIME $TIME_UNIT"
    write_info_message "Minimum time : $MIN_TIME $TIME_UNIT"
    write_info_message "Average time : $AVERAGE_TIME $TIME_UNIT"
    write_message "----------------------------------------------"
}

#Entry point
clear
echo

#Check number of arguments
if [ "$#" -ne 2 ]; then
    display_usage
    exit -1
fi

PROGRAM_NAME=$1
ITERATION_NUMBER=$2
#Validate arguments
validate_input

write_info_message "Benchmarking $PROGRAM_NAME $ITERATION_NUMBER times : "
execute_benchmark
calculate_results
display_results