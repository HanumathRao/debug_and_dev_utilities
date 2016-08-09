#!/bin/bash
MEMDUMP_PYTHON="memdump.py"
MEMDUMP_OUTPUT="memdump.txt"

function write_message()
{
    echo $1
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

#Entry point
clear
echo

#Check number of arguments
if [ "$#" -ne 1 ]; then
    write_message "Note : You have to give a debugee executable name."        
    exit -1
fi

DEBUGEE=$1

#Check if GDB exists , otherwise display message
is_command_valid "gdb"
GDB_AVAILABLE=$IS_COMMAND_VALID_RESULT
if [ $GDB_AVAILABLE -eq 0 ]; then
    write_message "Note : GDB does not exist in your system. Quitting."        
    exit -1
fi

#Delete previous output
sudo rm -f $MEMDUMP_OUTPUT
sudo touch $MEMDUMP_OUTPUT
python_script_full_path="./${MEMDUMP_PYTHON}"
gdb -batch -ex "source ${python_script_full_path}" -ex 'memdump' -ex 'r' ${DEBUGEE}
echo
write_message "To see the output , type and enter : cat ${MEMDUMP_OUTPUT}"
