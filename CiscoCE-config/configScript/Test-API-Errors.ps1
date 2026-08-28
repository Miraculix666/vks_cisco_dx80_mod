# Analyse Skript - Prüfe exakte API Antworten des DX80

param(
    [string]$DX80IP = "192.168.250.20",
    [string]$DX80User = "admin",
    [string]$DX80Password = ""
)

try {
    $DX80Password = & "$PSScriptRoot\..\configScript\Get-DX80Password.ps1" -ProvidedPassword $DX80Password
} catch {
    Write-Error $_
    return
}

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::SecurityProtocol = 3072
$base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${DX80User}:${DX80Password}"))
$headers = @{ "Authorization" = "Basic $base64"; "Content-Type" = "text/xml" }

# Test 1: Provisioning abstellen
$xmlProv = "<Configuration><Provisioning><Mode>Off</Mode></Provisioning></Configuration>"

try {
    Write-Host ">>> Sende: Provisioning Mode Off"
    $r = Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $xmlProv -TimeoutSec 10
    Write-Host "HTTP Request erfolgreich. DX80 Antwort:"
    Write-Host $r.OuterXml -ForegroundColor Yellow
}
catch {
    Write-Error $_
}

# Test 2: WebEngine anstellen
$xmlWeb = "<Configuration><WebEngine><Mode>On</Mode></WebEngine><Macros><Mode>On</Mode></Macros></Configuration>"
try {
    Write-Host "`n>>> Sende: WebEngine & Macros On"
    $r = Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $xmlWeb -TimeoutSec 10
    Write-Host "HTTP Request erfolgreich. DX80 Antwort:"
    Write-Host $r.OuterXml -ForegroundColor Yellow
}
catch {
    Write-Error $_
}
