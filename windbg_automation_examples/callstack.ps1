# Requires Debugging Tools for Windows
# Outputs call stack of target process
[string]$CDB_EXECUTABLE = """" + "C:\Program Files (x86)\Windows Kits\10\Debuggers\x86\cdb.exe" + """"

function attach_and_invoke_cdb_command([string]$debug_command, $debugee_process_name)
{
    [string]$ret = ""
    [string]$temp_file = "temp.txt"

    [string]$actual_debugee_process_name = [System.IO.Path]::GetFileName($debugee_process_name)

    $actual_debug_command = $debug_command
    [string]$expression = "${CDB_EXECUTABLE} -pn $actual_debugee_process_name -c " + """" + $actual_debug_command + """" + " >> $temp_file"

    if( (Test-Path $temp_file) -eq $true )
    {
        Remove-Item $temp_file -Force
    }

    cmd.exe /c $expression

    $ret = Get-Content $temp_file
    Remove-Item $temp_file -Force

    return $ret
}

Set-Location $PSScriptRoot
Clear-Host
$result = attach_and_invoke_cdb_command "!sym prompts;.reload;~*kb1000;qd" "debugee.exe"
Write-Host $result