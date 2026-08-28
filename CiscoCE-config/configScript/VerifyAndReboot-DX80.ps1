# Skript zum Reboot des DX80 (ASCII/Safe Version)

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
[System.Net.ServicePointManager]::SecurityProtocol = 3072 # TLS 1.2
$base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${DX80User}:${DX80Password}"))
$headers = @{ "Authorization" = "Basic $base64"; "Content-Type" = "text/xml" }

Write-Host "Die Einstellungen wurden im vorherigen Schritt erfolgreich per HTTPS uebertragen." -ForegroundColor Cyan
Write-Host "Reboot wird ausgefuehrt ($DX80IP)..." -ForegroundColor Yellow

$rebootPayload = @"
<Command>
  <SystemUnit>
    <Boot>
      <Action>Restart</Action>
    </Boot>
  </SystemUnit>
</Command>
"@

try {
    Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $rebootPayload -TimeoutSec 10 | Out-Null
    Write-Host ">>> Reboot Befehl erfolgreich gesendet! Das DX80 startet in Kuerze neu." -ForegroundColor Green
}
catch {
    try {
        Invoke-RestMethod -Uri "http://$DX80IP/putxml" -Method Post -Headers $headers -Body $rebootPayload -TimeoutSec 10 | Out-Null
        Write-Host ">>> Reboot Befehl erfolgreich gesendet! Das DX80 startet in Kuerze neu." -ForegroundColor Green
    }
    catch { 
        Write-Error "Reboot Fehler: $_" 
    }
}
