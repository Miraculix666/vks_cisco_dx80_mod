# Cisco DX80 Rescue Script (ASCII Version)
# Bricht das CUCM-Provisioning ab, aktiviert WebEngine, Macros und SIP
# und pusht abschliessend das Fonial SIP Profil und Dark Theme in kleinen Chunks.

param(
    [string]$DX80IP = "192.168.250.20",
    [string]$DX80User = "Administrator",
    [string]$DX80Password = "",
    [string]$TelekomRufnummer = "+4923656979837",
    [string]$TelekomSIPPasswort = "023654192Ma!",
    [string]$TelekomAnschlussart = "Privat",
    [string]$FonialUser = "Marius.Tyburski@gmail.com",
    [string]$FonialPasswort = "023654192Ma!",
    [string]$FonialProxy = "sip.fonial.de",
    [string]$Rufnummer1 = "023652969218",
    [string]$Rufnummer2 = "023652969219",
    [string]$Rufnummer3 = "023652969217"
)

# --- Passwort-Logik ---
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

function Push-Chunk {
    param([string]$name, [string]$xml)
    Write-Host ">>> Sende: $name" -ForegroundColor Yellow
    try {
        $r = Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $xml -TimeoutSec 10
        Write-Host "    [OK] Erfolgreich via HTTPS" -ForegroundColor Green
    }
    catch {
        try {
            $r = Invoke-RestMethod -Uri "http://$DX80IP/putxml" -Method Post -Headers $headers -Body $xml -TimeoutSec 10
            Write-Host "    [OK] Erfolgreich via HTTP" -ForegroundColor Green
        }
        catch { Write-Error "    [FEHLER] $_" }
    }
}

Write-Host "=== Cisco DX80 Rescue Start ===" -ForegroundColor Cyan
Write-Host "IP: $DX80IP | User: $DX80User"

# === CHUNK 1: Provisioning Mode auf Edge setzen ===
# Verhindert "Systembereitstellung erwartet" und blockiert keine Konfigs mehr
$xmlProv = @"
<Configuration>
  <Provisioning><Mode>Edge</Mode></Provisioning>
</Configuration>
"@
Push-Chunk "Provisioning Mode Edge" $xmlProv
Start-Sleep -Seconds 2  # Gerät Zeit geben, interne Prozesse zu beenden


# === CHUNK 2: WebEngine und Macros an ===
# Erlaubt Teams/Zoom Buttons und Custom UI Extensions
$xmlWebMac = @"
<Configuration>
  <WebEngine><Mode>On</Mode></WebEngine>
  <Macros><Mode>On</Mode></Macros>
  <UserInterface>
    <Features><HideAll>False</HideAll></Features>
  </UserInterface>
</Configuration>
"@
Push-Chunk "WebEngine & Macros ON" $xmlWebMac
Start-Sleep -Seconds 2


# === CHUNK 3: SIP Basis-Service an ===
$xmlSIPBase = @"
<Configuration>
  <NetworkServices><SIP><Mode>On</Mode></SIP></NetworkServices>
  <SIP><ListenPort>On</ListenPort></SIP>
</Configuration>
"@
Push-Chunk "SIP Base Services ON" $xmlSIPBase
Start-Sleep -Seconds 2


# === CHUNK 4: Telekom & Fonial SIP und Dark Theme ===
switch ($TelekomAnschlussart) {
    "Privat" { $sipProxy = "tel.t-online.de" }
    "Business" { $sipProxy = "sip-trunk.telekom.de" }
}
$sipURITelekom = "${TelekomRufnummer}@${sipProxy}"

$sipURIFonial1 = "${Rufnummer1}@${FonialProxy}"
$sipURIFonial2 = "${Rufnummer2}@${FonialProxy}"
$sipURIFonial3 = "${Rufnummer3}@${FonialProxy}"

$xmlSIPAndTheme = @"
<Configuration>
  <SIP>
    <Profile item="1">
      <URI>${sipURITelekom}</URI>
      <DisplayName>${TelekomRufnummer}</DisplayName>
      <Proxy item="1"><Address>${sipProxy}</Address></Proxy>
      <Authentication item="1">
        <UserName>${TelekomRufnummer}</UserName>
        <Password>${TelekomSIPPasswort}</Password>
      </Authentication>
      <DefaultTransport>TCP</DefaultTransport>
    </Profile>
    <Profile item="2">
      <URI>${sipURIFonial1}</URI>
      <DisplayName>${Rufnummer1}</DisplayName>
      <Proxy item="1"><Address>${FonialProxy}</Address></Proxy>
      <Authentication item="1">
        <UserName>${FonialUser}</UserName>
        <Password>${FonialPasswort}</Password>
      </Authentication>
      <DefaultTransport>TCP</DefaultTransport>
    </Profile>
    <Profile item="3">
      <URI>${sipURIFonial2}</URI>
      <DisplayName>${Rufnummer2}</DisplayName>
      <Proxy item="1"><Address>${FonialProxy}</Address></Proxy>
      <Authentication item="1">
        <UserName>${FonialUser}</UserName>
        <Password>${FonialPasswort}</Password>
      </Authentication>
      <DefaultTransport>TCP</DefaultTransport>
    </Profile>
    <Profile item="4">
      <URI>${sipURIFonial3}</URI>
      <DisplayName>${Rufnummer3}</DisplayName>
      <Proxy item="1"><Address>${FonialProxy}</Address></Proxy>
      <Authentication item="1">
        <UserName>${FonialUser}</UserName>
        <Password>${FonialPasswort}</Password>
      </Authentication>
      <DefaultTransport>TCP</DefaultTransport>
    </Profile>
    <TlsVerify>Off</TlsVerify>
    <Ice><Mode>Off</Mode></Ice>
  </SIP>
  <UserInterface>
    <Branding><AwakeBranding><Colors>Native</Colors></AwakeBranding></Branding>
    <OSD><EncryptionIndicator>Off</EncryptionIndicator></OSD>
    <KeyTones><Mode>Off</Mode></KeyTones>
  </UserInterface>
</Configuration>
"@
Push-Chunk "Telekom & Fonial SIP Profile & Dark Theme" $xmlSIPAndTheme
Start-Sleep -Seconds 2

# === CHUNK 4.5: System Passphrase setzen ===
$NewSystemPassphrase = "023654192"
$xmlPassphraseCmd = @"
<Command>
  <UserManagement>
    <User>
      <Passphrase>
        <Set>
          <Username>$DX80User</Username>
          <Passphrase>$NewSystemPassphrase</Passphrase>
        </Set>
      </Passphrase>
    </User>
  </UserManagement>
</Command>
"@
Push-Chunk "System Passphrase auf $NewSystemPassphrase setzen" $xmlPassphraseCmd
Start-Sleep -Seconds 2


# === CHUNK 5: Reboot ===
Write-Host "Reboot wird ausgefuehrt..." -ForegroundColor Cyan
$rebootPayload = "<Command><SystemUnit><Boot><Action>Restart</Action></Boot></SystemUnit></Command>"
$headers.Add("Content-Type", "text/xml")  # Muss nochmal explizit drin sein, wenn Hash überschrieben wird (sicher ist sicher)
$headers = @{ "Authorization" = "Basic $base64"; "Content-Type" = "text/xml" }

try {
    Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $rebootPayload -TimeoutSec 10 | Out-Null
    Write-Host ">>> Reboot Befehl erfolgreich gesendet! Das DX80 startet neu." -ForegroundColor Green
}
catch {
    try {
        Invoke-RestMethod -Uri "http://$DX80IP/putxml" -Method Post -Headers $headers -Body $rebootPayload -TimeoutSec 10 | Out-Null
        Write-Host ">>> Reboot Befehl erfolgreich gesendet! Das DX80 startet neu." -ForegroundColor Green
    }
    catch { Write-Error "Reboot Fehler: $_" }
}

Write-Host "=== Rescue Done ===" -ForegroundColor Cyan
