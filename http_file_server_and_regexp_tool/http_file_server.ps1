param([string]$file="conf_tool.htm", [int]$port=8081)

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

    [string]$http_method = $context.Request.HttpMethod.ToString()
    [string]$requested_url = $context.Request.Url
    Write-Host ''
    Write-Host "> $requested_url"

    if( $http_method.ToUpper() -eq "GET" )
    {
        Write-Host ""
        Write-Host "Handling GET METHOD"
        Write-Host ""
        $response.ContentLength64 = $FILE_BUFFER.Length
        $response.OutputStream.Write($FILE_BUFFER, 0, $FILE_BUFFER.Length)
        $response.Close()
    }
    else
    {
        Write-Host ""
        Write-Host ( "Non supported verb : " + $http_method.ToUpper() )
        Write-Host ""
    }

    $responseStatus = $response.StatusCode
    Write-Host "< $responseStatus"
}

exit 0