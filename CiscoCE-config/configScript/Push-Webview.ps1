param(
    [string]$DX80IP = "192.168.250.20",
    [string]$DX80User = "admin",
    [string]$DX80Password = "",
    [string]$Url = "https://zoom.us/join",
    [ValidateSet("WebView", "Signage")]
    [string]$Method = "WebView"
)

# --- credentials.xml laden ---
try {
    $DX80Password = & "$PSScriptRoot\..\configScript\Get-DX80Password.ps1" -ProvidedPassword $DX80Password
} catch {
    Write-Error $_
    return
}

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::SecurityProtocol = 3072 # TLS 1.2
$base64Auth = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${DX80User}:${DX80Password}"))
$headers = @{ "Authorization" = "Basic $base64Auth"; "Content-Type" = "text/xml" }

function Push-DX80Xml {
    param([string]$xml)
    try {
        $response = Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $xml -TimeoutSec 10
        Write-Host "Success: $($response.OuterXml)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Error: $_"
        return $false
    }
}

if ($Method -eq "WebView") {
    Write-Host ">>> Testing WebView Display: $Url" -ForegroundColor Cyan
    $xml = "<Command><UserInterface><WebView><Display><Url>$Url</Url></Display></WebView></UserInterface></Command>"
}
elseif ($Method -eq "Signage") {
    Write-Host ">>> Testing Digital Signage: $Url" -ForegroundColor Cyan
    $xml = @"
<Configuration>
  <Standby>
    <Signage>
      <Mode>On</Mode>
      <Url>$Url</Url>
      <Audio>Off</Audio>
      <InteractiveMode>On</InteractiveMode>
    </Signage>
  </Standby>
</Configuration>
"@
}

Push-DX80Xml $xml
