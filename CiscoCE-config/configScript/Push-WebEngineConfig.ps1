param(
    [Parameter(Mandatory = $true)]
    [string]$Username,
    [Parameter(Mandatory = $true)]
    [string]$Password
)

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls

$bytes = [System.Text.Encoding]::ASCII.GetBytes("$($Username):$($Password)")
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{"Authorization" = "Basic $base64"; "Content-Type" = "text/xml" }

$xmlPayload = @"
<Configuration>
  <UserInterface>
    <WebEngine>
      <Mode>On</Mode>
      <Features>
        <URLBar>On</URLBar>
      </Features>
    </WebEngine>
  </UserInterface>
</Configuration>
"@

try {
    $response = Invoke-RestMethod -Uri "https://192.168.250.20/putxml" -Method Post -Headers $headers -Body $xmlPayload -TimeoutSec 10
    Write-Host "Success: $($response.OuterXml)"
}
catch {
    Write-Host "HTTPS failed: $_"
    try {
        $response = Invoke-RestMethod -Uri "http://192.168.250.20/putxml" -Method Post -Headers $headers -Body $xmlPayload -TimeoutSec 10
        Write-Host "HTTP Success: $($response.OuterXml)"
    }
    catch {
        Write-Host "HTTP failed: $_"
    }
}
