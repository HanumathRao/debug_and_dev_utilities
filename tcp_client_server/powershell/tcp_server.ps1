param( $port = 666 )

function start_server ($port_number) 
{   
  try
  {
    $endpoint = New-Object -TypeName System.Net.IPEndPoint -ArgumentList ([System.Net.ipaddress]::any, $port_number)
    $listener = New-Object -TypeName System.Net.Sockets.TcpListener -ArgumentList $endpoint
    $listener.start()
  }
  catch [System.Exception]
  {
    Write-Host -Object $_.Exception.Message
    return $false
  }
        
  #Accept connections and display messages
  do 
  {
    $client = $listener.AcceptTcpClient() # BLOCKING

    $stream = $client.GetStream()
    $reader = New-Object -TypeName System.IO.StreamReader -ArgumentList $stream
    [string]$line = $reader.ReadLine()

    Write-Host Received message $line from $client.Client.LocalEndPoint.ToString()  -ForegroundColor cyan

    $reader.Dispose()
    $stream.Dispose()
    $client.Dispose()
  } 
  while ( $line.ToLower() -ne 'quit')
    
  $listener.stop()
  Write-Host Server ending

  return $true
}

$exit_code = 0
Write-Host
Write-Host Server starting to listen on port $port
Write-Host
if( start_server $port -ne $true )
{
  $exit_code = -1
}
exit $exit_code