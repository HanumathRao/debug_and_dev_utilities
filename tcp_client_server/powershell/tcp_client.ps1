param($server = 'localhost', $port, $message )

function send_message ($server, $port, $message) 
{
  try
  {
    $client = New-Object -TypeName System.Net.Sockets.TcpClient -ArgumentList $server, $port
  }
  catch [System.Exception]
  {
    Write-Host -Object $_.Exception.Message
    return $false
  }
    
  $stream = $client.GetStream()
  $writer = New-Object -TypeName System.IO.StreamWriter -ArgumentList $stream
  $writer.Write($message)
   
  $writer.Dispose()
  $stream.Dispose()
  $client.Dispose()
  return $true
}

$exit_code = 0
if( (send_message $server $port $message) -ne $true )
{
  $exit_code = -1
}
exit $exit_code