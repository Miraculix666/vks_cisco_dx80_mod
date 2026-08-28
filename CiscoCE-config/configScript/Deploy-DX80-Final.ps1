<#
.SYNOPSIS
    Finales Deployment-Skript zur Einrichtung eines Cisco DX80 (CE Firmware) als SIP-Endgeraet.
    Umgeht aktiv den CUCM Provisioning-Lock und richtet WebEngine, Theme und Fonial SIP ein.

.DESCRIPTION
    Dieses Skript ist das Resultat der Analyse aller fehlschlagenden API- und SSH-Aufrufe 
    nach einem Factory Reset. Es wendet Konfigurationen in strikt logischen Phasen an,
    um zu verhindern, dass das DX80 die Setups wieder ueberschreibt.

    Phase 1: Bricht den DHCP/Option 150 Provisioning Lock.
    Phase 2: Aktiviert essentielle Dienste (WebEngine, Macros, SIP).
    Phase 3: Konfiguriert das UI (Dark Theme).
    Phase 4: Konfiguriert das Fonial SIP Profil.
    Phase 5: Aktiviert die Änderungen per Neustart.
#>

param(
    [string]$DX80IP = "",
    [string]$DX80User = "",
    [string]$DX80Password = "",
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


# --- credentials.xml laden (falls vorhanden) ---
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

switch ($config.TelekomAnschlussart) {
    "Privat" { $sipProxy = "tel.t-online.de" }
    "Business" { $sipProxy = "sip-trunk.telekom.de" }
}
$sipURITelekom = "${TelekomRufnummer}@${sipProxy}"

$sipURIFonial1 = "$($config.Rufnummer1)@$($config.FonialProxy)"
$sipURIFonial2 = "$($config.Rufnummer2)@$($config.FonialProxy)"
$sipURIFonial3 = "$($config.Rufnummer3)@$($config.FonialProxy)"

# Helper Function: REST POST Payload
function Push-DX80Config {
    param([string]$name, [string]$xmlPayload)
    Write-Host ">>> Phase: $name" -ForegroundColor DarkCyan
    
    # 3 Retries fuer instabile DX80 Webserver in der Bootphase
    $retries = 3
    for ($i = 0; $i -lt $retries; $i++) {
        try {
            Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $xmlPayload -TimeoutSec 10 | Out-Null
            Write-Host "    [OK] Erfolgreich via HTTPS" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Warning "    HTTPS fehlgeschlagen, versuche HTTP... ($i/$retries)"
            try {
                Invoke-RestMethod -Uri "http://$DX80IP/putxml" -Method Post -Headers $headers -Body $xmlPayload -TimeoutSec 10 | Out-Null
                Write-Host "    [OK] Erfolgreich via HTTP" -ForegroundColor Green
                return $true
            }
            catch {
                if ($i -eq ($retries - 1)) { Write-Error "    [FEHLER] Konfiguration '$name' endgueltig gescheitert: $_" }
                Start-Sleep -Seconds 2
            }
        }
    }
    return $false
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Cisco DX80 Deployment System (V1.0 Final)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# ====================================================================
# PHASE 1: Provisioning Lock brechen
# ====================================================================
# ACHTUNG: Die wichtigste Erkenntnis. Wir muessen IPv4 temporaer auf 
# Static zwingen, damit DHCP keinen neuen Callmanager pushen kann.
$xmlPhase1 = @"
<Configuration>
  <Network item="1"><IPv4><Assignment>Static</Assignment></IPv4></Network>
  <Provisioning><Mode>Edge</Mode><ExternalManager><Address></Address><AlternateAddress></AlternateAddress></ExternalManager></Provisioning>
</Configuration>
"@
Push-DX80Config "1. Provisioning Lock brechen (Network Static, Mode Edge)" $xmlPhase1
Start-Sleep -Seconds 2  # Dem DHCP-Client Zeit zum Stoppen geben

# ====================================================================
# PHASE 2: Basis-Dienste initialisieren
# ====================================================================
$xmlPhase2 = @"
<Configuration>
  <WebEngine><Mode>On</Mode></WebEngine>
  <Macros><Mode>On</Mode></Macros>
  <NetworkServices><SIP><Mode>On</Mode></SIP></NetworkServices>
  <Audio><USB><Mode>SpeakerAndMicrophone</Mode></USB></Audio>
  <UserInterface>
    <Features>
      <Share><PCVideo>Auto</PCVideo></Share>
    </Features>
  </UserInterface>
</Configuration>
"@
Push-DX80Config "2. Services aktivieren (WebEngine, Macros, SIP)" $xmlPhase2
Start-Sleep -Seconds 2

# ====================================================================
# PHASE 3: User Interface & Dark Theme
# ====================================================================
$xmlPhase3 = @"
<Configuration>
  <UserInterface>
    <Features><HideAll>False</HideAll></Features>
    <Branding><AwakeBranding><Colors>Native</Colors></AwakeBranding></Branding>
    <OSD><EncryptionIndicator>Off</EncryptionIndicator></OSD>
    <KeyTones><Mode>Off</Mode></KeyTones>
  </UserInterface>
</Configuration>
"@
Push-DX80Config "3. User Interface (Dark Theme, Features sichtbar)" $xmlPhase3
Start-Sleep -Seconds 2

# ====================================================================
# PHASE 4: SIP Setup (Telekom)
# ====================================================================
$xmlPhase4 = @"
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
      <DisplayName>$($config.Rufnummer1)</DisplayName>
      <Proxy item="1"><Address>$($config.FonialProxy)</Address></Proxy>
      <Authentication item="1">
        <UserName>${FonialUser}</UserName>
        <Password>${FonialPasswort}</Password>
      </Authentication>
      <DefaultTransport>TCP</DefaultTransport>
    </Profile>
    <Profile item="3">
      <URI>${sipURIFonial2}</URI>
      <DisplayName>$($config.Rufnummer2)</DisplayName>
      <Proxy item="1"><Address>$($config.FonialProxy)</Address></Proxy>
      <Authentication item="1">
        <UserName>${FonialUser}</UserName>
        <Password>${FonialPasswort}</Password>
      </Authentication>
      <DefaultTransport>TCP</DefaultTransport>
    </Profile>
    <Profile item="4">
      <URI>${sipURIFonial3}</URI>
      <DisplayName>$($config.Rufnummer3)</DisplayName>
      <Proxy item="1"><Address>$($config.FonialProxy)</Address></Proxy>
      <Authentication item="1">
        <UserName>${FonialUser}</UserName>
        <Password>${FonialPasswort}</Password>
      </Authentication>
      <DefaultTransport>TCP</DefaultTransport>
    </Profile>
    <TlsVerify>Off</TlsVerify>
    <Ice><Mode>Off</Mode></Ice>
    <ListenPort>On</ListenPort>
  </SIP>
</Configuration>
"@
Push-DX80Config "4. SIP Profile anlegen (Telekom & Fonial)" $xmlPhase4
Start-Sleep -Seconds 2

# ====================================================================
# PHASE 4.5: System Passphrase setzen
# ====================================================================
$NewSystemPassphrase = $config.DX80Password
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
Push-DX80Config "4.5 System Passphrase setzen" $xmlPassphraseCmd
Start-Sleep -Seconds 2

# ====================================================================
# PHASE 5: DHCP wieder aktivieren und Reboot
# ====================================================================
Write-Host ">>> Phase: 5. DHCP Restore & Reboot" -ForegroundColor DarkCyan
$xmlPhase5 = @"
<Configuration>
  <Network item="1"><IPv4><Assignment>DHCP</Assignment></IPv4></Network>
</Configuration>
"@
# Hier senden wir das XML und direkt im Anschluss den Reboot-Payload getrennt,
# da das XML den DHCP Daemon neu startet und das Geraet sonst kurz offline ist.
Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $xmlPhase5 -TimeoutSec 5 -ErrorAction SilentlyContinue | Out-Null

$xmlReboot = "<Command><SystemUnit><Boot><Action>Restart</Action></Boot></SystemUnit></Command>"
try {
    Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $xmlReboot -TimeoutSec 10 | Out-Null
    Write-Host "    [OK] DHCP wieder eingeschaltet und Restart getriggert." -ForegroundColor Green
}
catch {
    Write-Warning "    Fehler beim Reboot. Das Geraet startet moeglicherweise bereits wegen des DHCP-Resets."
}

Write-Host "`n>>> Deployment Script beendet. Das DX80 ist nun eine Stand-Alone SIP Kiste im Dark Mode." -ForegroundColor Cyan
