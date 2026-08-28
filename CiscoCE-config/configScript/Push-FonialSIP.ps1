# Cisco DX80 - Fonial SIP Profil 2 einrichten
# Fonial SIP-Daten aus Kundenkonto: Konto -> Ziele -> Benutzer-Symbol mit Zahnrad

param(
    [string]$DX80IP = "192.168.250.20",
    [string]$DX80User = "admin",
    [string]$DX80Pass = "",
    # Aus Fonial-Kundenkonto (Konto -> Ziele -> Zahnrad-Icon):
    [string]$FonialUser = "",   # Benutzername (z.B. 12345678)
    [string]$FonialPass = "",   # Passwort
    [string]$FonialServer = "sip.fonial.de",
    [string]$FonialExtension = ""    # Anzeigename / Durchwahl
)

if ([string]::IsNullOrWhiteSpace($FonialUser) -or [string]::IsNullOrWhiteSpace($FonialPass)) {
    Write-Error "Bitte -FonialUser und -FonialPass angeben (aus Fonial-Kundenkonto)."
    Write-Host "Beispiel: .\Push-FonialSIP.ps1 -FonialUser '12345678' -FonialPass 'MeinPasswort' -FonialExtension 'Buero'"
    return
}

# Passwort laden
try {
    $DX80Pass = & "$PSScriptRoot\..\configScript\Get-DX80Password.ps1" -ProvidedPassword $DX80Pass
} catch {
    Write-Error $_
    return
}

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::SecurityProtocol = 3072
$b64 = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${DX80User}:${DX80Pass}"))
$headers = @{ "Authorization" = "Basic $b64"; "Content-Type" = "text/xml" }

$displayName = if ($FonialExtension) { $FonialExtension } else { $FonialUser }
$sipURI = "${FonialUser}@${FonialServer}"

# Fonial SIP Profile an Profil 2 haengen
$xml = @"
<Configuration>
  <SIP>
    <Profile item="2">
      <URI>${sipURI}</URI>
      <DisplayName>${displayName}</DisplayName>
      <Proxy item="1"><Address>${FonialServer}</Address></Proxy>
      <Authentication item="1">
        <UserName>${FonialUser}</UserName>
        <Password>${FonialPass}</Password>
      </Authentication>
      <DefaultTransport>TCP</DefaultTransport>
    </Profile>
    <TlsVerify>Off</TlsVerify>
    <Ice><Mode>Off</Mode></Ice>
    <ListenPort>On</ListenPort>
  </SIP>
</Configuration>
"@

try {
    Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $xml -TimeoutSec 10 | Out-Null
    Write-Host "[OK] Fonial SIP Profil 2 gesetzt: $sipURI" -ForegroundColor Green
    Write-Host "     DisplayName: $displayName"
    Write-Host "     Server:      $FonialServer"
}
catch {
    Write-Warning "HTTPS fehlgeschlagen, versuche HTTP..."
    try {
        Invoke-RestMethod -Uri "http://$DX80IP/putxml" -Method Post -Headers $headers -Body $xml -TimeoutSec 10 | Out-Null
        Write-Host "[OK] Fonial SIP Profil 2 gesetzt: $sipURI (HTTP)" -ForegroundColor Green
    }
    catch { Write-Error "Fehler: $_" }
}
