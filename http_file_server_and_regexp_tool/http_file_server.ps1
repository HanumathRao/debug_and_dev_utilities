param([string]$file="regexp_tool.htm", [int]$port=8080)

Clear-Host
Set-Location $PSScriptRoot

if(! (Test-Path $file ) )
{
    Write-Host "Requested file ( $file ) does not exist"
    exit 1
}

$FILE_CONTENT = [IO.File]::ReadAllText($file)
$FILE_BUFFER = [System.Text.Encoding]::UTF8.GetBytes($FILE_CONTENT)


[string]$url = 'http://localhost:'
$url += $port.ToString()
$url += "/"
$web_server = New-Object System.Net.HttpListener
$web_server.Prefixes.Add($url)
$web_server.Start()

while ($web_server.IsListening)
{
    $context = $web_server.GetContext()
    $response = $context.Response
    
    [string]$requested_url = $context.Request.Url
    
    Write-Host ''
    Write-Host "> $requested_url"
    
    $response.ContentLength64 = $FILE_BUFFER.Length
    $response.OutputStream.Write($FILE_BUFFER, 0, $FILE_BUFFER.Length)
    $response.Close()
    
    $responseStatus = $response.StatusCode
    Write-Host "< $responseStatus"
}

exit 0