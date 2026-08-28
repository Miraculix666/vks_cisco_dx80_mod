# Cisco DX80 Telekom SIP Konfiguration (ASCII/Safe Version)
# Fixed: Default User is "admin"

param(
    [Parameter(Mandatory = $true)]
    [string]$TelekomRufnummer,

    [Parameter(Mandatory = $true)]
    [string]$TelekomSIPPasswort,

    [string]$DX80IP = "192.168.250.20",
    [string]$DX80User = "admin",
    [string]$DX80Password = "",
    [ValidateSet("Privat", "Business")]
    [string]$TelekomAnschlussart = "Privat",
    [string]$DisplayName = ""
)

# --- Passwort-Logik ---
try {
    $DX80Password = & "$PSScriptRoot\..\configScript\Get-DX80Password.ps1" -ProvidedPassword $DX80Password
} catch {
    Write-Error $_
    return
}

# --- SIP-Logik ---
switch ($TelekomAnschlussart) {
    "Privat" { $sipProxy = "tel.t-online.de" }
    "Business" { $sipProxy = "sip-trunk.telekom.de" }
}
$sipURI = "${TelekomRufnummer}@${sipProxy}"
if ([string]::IsNullOrWhiteSpace($DisplayName)) { $DisplayName = $TelekomRufnummer }

# --- API-Vorbereitung ---
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::SecurityProtocol = 3072 # TLS 1.2
$base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${DX80User}:${DX80Password}"))
$headers = @{ "Authorization" = "Basic $base64"; "Content-Type" = "text/xml" }

$xmlPayload = @"
<Configuration>
  <SIP>
    <URI>${sipURI}</URI>
    <DisplayName>${DisplayName}</DisplayName>
    <Proxy item="1"><Address>${sipProxy}</Address></Proxy>
    <Authentication>
      <UserName>${TelekomRufnummer}</UserName>
      <Password>${TelekomSIPPasswort}</Password>
    </Authentication>
    <DefaultTransport>TCP</DefaultTransport>
    <TlsVerify>Off</TlsVerify>
    <ListenPort>On</ListenPort>
    <Ice><Mode>Off</Mode></Ice>
  </SIP>
  <NetworkServices><SIP><Mode>On</Mode></SIP></NetworkServices>
  <Provisioning><Mode>Edge</Mode></Provisioning>
</Configuration>
"@

Write-Host "--- Sende Konfiguration an $DX80IP (User: $DX80User) ---"
try {
    $r = Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $xmlPayload -TimeoutSec 15
    Write-Host "Erfolgreich via HTTPS"
}
catch {
    try {
        $r = Invoke-RestMethod -Uri "http://$DX80IP/putxml" -Method Post -Headers $headers -Body $xmlPayload -TimeoutSec 15
        Write-Host "Erfolgreich via HTTP"
    }
    catch { Write-Error "Fehler: $_" }
}
