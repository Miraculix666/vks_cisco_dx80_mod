# Cisco DX80 Rescue V2 (Permanent Provisioning Break)

param(
    [string]$DX80IP = "192.168.250.20",
    [string]$DX80User = "Administrator",
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

# Dieser XML Block ist entscheidend:
# 1. Wir verbieten DHCP, uns Provisioning-Server unterzuschieben
# 2. Wir loeschen ExternalManager Adressen
# 3. Wir setzen Provisioning auf Off
$xmlKillProv = @"
<Configuration>
  <Network item="1">
    <IPv4>
      <Assignment>Static</Assignment>
    </IPv4>
  </Network>
  <Provisioning>
    <Mode>Off</Mode>
    <ExternalManager>
      <Address></Address>
      <AlternateAddress></AlternateAddress>
    </ExternalManager>
  </Provisioning>
</Configuration>
"@

Write-Host ">>> Sende: Permanent Provisioning Kill" -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "http://$DX80IP/putxml" -Method Post -Headers $headers -Body $xmlKillProv -TimeoutSec 10 | Out-Null
    Write-Host "    [OK] DHCP Assignment auf Static geaendert, Provisioning Mode Off" -ForegroundColor Green
}
catch {
    try {
        Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $xmlKillProv -TimeoutSec 10 | Out-Null
        Write-Host "    [OK] DHCP Assignment auf Static geaendert, Provisioning Mode Off" -ForegroundColor Green
    }
    catch { Write-Error $_ }
}

Start-Sleep -Seconds 2

# Da wir IPv4 auf Static zwingen mussten, um DHCP Option 150 zu toeten, 
# setzen wir WebEngine, Theme und Macros ebenfalls direkt 
$xmlRest = @"
<Configuration>
  <WebEngine><Mode>On</Mode></WebEngine>
  <Macros><Mode>On</Mode></Macros>
  <UserInterface>
    <Features><HideAll>False</HideAll></Features>
    <Branding><AwakeBranding><Colors>Native</Colors></AwakeBranding></Branding>
    <OSD><EncryptionIndicator>Off</EncryptionIndicator></OSD>
  </UserInterface>
  <NetworkServices><SIP><Mode>On</Mode></SIP></NetworkServices>
</Configuration>
"@

Write-Host ">>> Sende: UI, WebEngine, Theme" -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "http://$DX80IP/putxml" -Method Post -Headers $headers -Body $xmlRest -TimeoutSec 10 | Out-Null
    Write-Host "    [OK] UI Konfigurationen gesetzt" -ForegroundColor Green
}
catch {
    try { Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $xmlRest -TimeoutSec 10 | Out-Null; Write-Host "    [OK]" -ForegroundColor Green } 
    catch { Write-Error $_ }
}

Write-Host ">>> Bitte rebooten Sie das Geraet (Hard-Reset) oder per Skript." -ForegroundColor Cyan
