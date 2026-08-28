<#
.SYNOPSIS
    Master Deployment-Skript für Cisco DX80 (CE Firmware).
    Integriert Konfiguration, SIP-Setup, UI-Extensions, Macros und Hintergrundbild.

.DESCRIPTION
    Dieses Skript konsolidiert alle Einzelschritte zur Einrichtung eines "unchained" DX80.
    Es bricht den Provisioning Lock, aktiviert die WebEngine, richtet SIP ein und 
    installiert die Meeting-Shortcuts sowie Persistenz-Macros.
#>

param(
    [string]$DX80IP = "",
    [string]$DX80User = "",
    [string]$DX80Password = "",
    

    # Files
    [string]$BackgroundPath = "$PSScriptRoot\background.png",
    [string]$UIExtensionPath = "$PSScriptRoot\MeetingShortcuts_UI.xml"
)

# Load configuration from JSON
$configPath = Join-Path -Path $PSScriptRoot -ChildPath "config.template.json"
$config = Get-Content -Path $configPath | ConvertFrom-Json

if ([string]::IsNullOrWhiteSpace($DX80IP)) { $DX80IP = $config.DX80IP }
if ([string]::IsNullOrWhiteSpace($DX80User)) { $DX80User = $config.DX80User }
if ([string]::IsNullOrWhiteSpace($DX80Password)) { $DX80Password = $config.DX80Password }
$TelekomRufnummer = $config.TelekomRufnummer
$TelekomSIPPasswort = $config.TelekomSIPPasswort
$FonialUser = $config.FonialUser
$FonialPasswort = $config.FonialPasswort


# --- Passwort laden ---
try {
    $DX80Password = & "$PSScriptRoot\..\configScript\Get-DX80Password.ps1" -ProvidedPassword $DX80Password
} catch {
    Write-Error $_
    return
}

# --- Variablen Setup ---
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::SecurityProtocol = 3072 # TLS 1.2
$base64Auth = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${DX80User}:${DX80Password}"))
$headers = @{ "Authorization" = "Basic $base64Auth"; "Content-Type" = "text/xml" }

# Helper Function: REST POST Payload
function Push-DX80Config {
    param([string]$name, [string]$xmlPayload)
    Write-Host ">>> Phase: $name" -ForegroundColor DarkCyan
    
    $retries = 3
    for ($i = 0; $i -lt $retries; $i++) {
        try {
            Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $xmlPayload -TimeoutSec 15 | Out-Null
            Write-Host "    [OK]" -ForegroundColor Green
            return $true
        }
        catch {
            if ($i -eq ($retries - 1)) { Write-Error "    [FEHLER] '$name' gescheitert: $_" }
            Start-Sleep -Seconds 2
        }
    }
    return $false
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host " Cisco DX80 Integrated Deployment Master" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# --- PHASE 1: Provisioning Lock & Basis ---
$xmlPhase1 = @"
<Configuration>
  <Network item="1"><IPv4><Assignment>Static</Assignment></IPv4></Network>
  <Provisioning><Mode>Edge</Mode></Provisioning>
  <WebEngine><Mode>On</Mode></WebEngine>
  <Macros><Mode>On</Mode></Macros>
  <NetworkServices><SIP><Mode>On</Mode></NetworkServices>
  <Audio><USB><Mode>SpeakerAndMicrophone</Mode></USB></Audio>
</Configuration>
"@
Push-DX80Config "1. Lock brechen & Basis-Dienste" $xmlPhase1

# --- PHASE 2: SIP Setup ---
$xmlSIP = @"
<Configuration>
  <SIP>
    <Profile item="1">
      <URI>${TelekomRufnummer}@tel.t-online.de</URI>
      <DisplayName>Telekom</DisplayName>
      <Proxy item="1"><Address>tel.t-online.de</Address></Proxy>
      <Authentication item="1"><UserName>${TelekomRufnummer}</UserName><Password>${TelekomSIPPasswort}</Password></Authentication>
    </Profile>
    <Profile item="2">
      <URI>$($config.Rufnummer1)@$($config.FonialProxy)</URI>
      <DisplayName>Fonial 1</DisplayName>
      <Proxy item="1"><Address>$($config.FonialProxy)</Address></Proxy>
      <Authentication item="1"><UserName>${FonialUser}</UserName><Password>${FonialPasswort}</Password></Authentication>
    </Profile>
  </SIP>
</Configuration>
"@
Push-DX80Config "2. SIP Profile (Telekom & Fonial)" $xmlSIP

# --- PHASE 3: Background Upload ---
if (Test-Path $BackgroundPath) {
    Write-Host ">>> Phase: 3. Hintergrundbild hochladen" -ForegroundColor DarkCyan
    try {
        $imageBytes = [System.IO.File]::ReadAllBytes($BackgroundPath)
        $boundary = [guid]::NewGuid().ToString()
        
        $ms = New-Object System.IO.MemoryStream
        $enc = [System.Text.Encoding]::Latin1
        $hdr = "--${boundary}`r`nContent-Disposition: form-data; name=`"file`"; filename=`"bg.png`"`r`nContent-Type: image/png`r`n`r`n"
        $ftr = "`r`n--${boundary}--`r`n"
        $hdrBytes = $enc.GetBytes($hdr)
        $ftrBytes = $enc.GetBytes($ftr)
        $ms.Write($hdrBytes, 0, $hdrBytes.Length)
        $ms.Write($imageBytes, 0, $imageBytes.Length)
        $ms.Write($ftrBytes, 0, $ftrBytes.Length)
        $bodyStream = $ms.ToArray()

        $uploadHeaders = @{ "Authorization" = "Basic $base64Auth"; "Content-Type" = "multipart/form-data; boundary=$boundary" }
        Invoke-RestMethod -Uri "https://$DX80IP/api/v1/userinterface/presentation/background" -Method Put -Headers $uploadHeaders -Body $bodyStream -TimeoutSec 30 | Out-Null
        Write-Host "    [OK]" -ForegroundColor Green
    }
    catch { Write-Warning "    Hintergrund-Upload gescheitert (Oft Firmware-limitierung)" }
}

# --- PHASE 4: UI Extensions ---
if (Test-Path $UIExtensionPath) {
    $uiContent = Get-Content $UIExtensionPath -Raw
    $uiPayload = "<Command><UserInterface><Extensions><Set><Panel>$($uiContent)</Panel></Set></Extensions></UserInterface></Command>"
    Push-DX80Config "4. UI Extensions (Teams/Zoom)" $uiPayload
}

# --- PHASE 5: Macros ---
$macroFiles = @(
    @{ Name = "MeetingShortcuts"; Path = "$PSScriptRoot\MeetingShortcuts.js" },
    @{ Name = "SystemMonitor"; Path = "$PSScriptRoot\SystemMonitor.js" },
    @{ Name = "UsbWebcamPersistent"; Path = "$PSScriptRoot\UsbWebcamPersistent.js" }
)

foreach ($m in $macroFiles) {
    if (Test-Path $m.Path) {
        $body = (Get-Content $m.Path -Raw) -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'
        $xmlM = "<Command><Macros><Macro><Save><Name>$($m.Name)</Name><Body>$body</Body><Overwrite>True</Overwrite></Save></Macro></Macros></Command>"
        Push-DX80Config "5. Macro: $($m.Name)" $xmlM
    }
}

# --- PHASE 6: Finalize & Restart ---
$xmlFinal = @"
<Configuration>
  <Network item="1"><IPv4><Assignment>DHCP</Assignment></IPv4></Network>
  <Macros><AutoStart>On</AutoStart></Macros>
</Configuration>
"@
Push-DX80Config "6. DHCP Restore & AutoStart" $xmlFinal

Write-Host "`n>>> Deployment abgeschlossen. Empfehlung: Manueller Reboot via Web UI." -ForegroundColor Cyan
