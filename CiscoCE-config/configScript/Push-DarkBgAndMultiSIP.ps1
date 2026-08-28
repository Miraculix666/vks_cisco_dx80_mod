# Cisco DX80 - Dunkles Hintergrundbild hochladen und Multi-SIP konfigurieren
# Dark Theme ist auf dem DX80 CE 9.15 NUR per Hintergrundbild moeglich!
# WebEngine ist hardwareseitig NICHT unterstuetzt (ARM Cortex-A9).

param(
    [string]$DX80IP = "192.168.250.20",
    [string]$DX80User = "admin",
    [string]$DX80Password = "",
    [string]$ImagePath = "",
    
    # Optional: Zweites SIP Profil
    [string]$SIP2Rufnummer = "",
    [string]$SIP2Passwort = "",
    [string]$SIP2Proxy = "sip.fonial.de"
)

# Passwort laden
try {
    $DX80Password = & "$PSScriptRoot\..\configScript\Get-DX80Password.ps1" -ProvidedPassword $DX80Password
} catch {
    Write-Error $_
    return
}

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::SecurityProtocol = 3072
$base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${DX80User}:${DX80Password}"))

Write-Host "=== DX80 Dark Background + Multi-SIP ===" -ForegroundColor Cyan

# --- 1. Hintergrundbild als Base64 uploaden ---
if ($ImagePath -and (Test-Path $ImagePath)) {
    Write-Host "Lade Hintergrundbild hoch: $ImagePath"
    $imageBytes = [System.IO.File]::ReadAllBytes($ImagePath)
    $base64img = [System.Convert]::ToBase64String($imageBytes)
    $ext = [System.IO.Path]::GetExtension($ImagePath).ToUpper().TrimStart('.')
    
    # Hintergrundbild via HTTP multipart Upload auf DX80
    $boundary = [guid]::NewGuid().ToString()
    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"file`"; filename=`"background.$ext`"",
        "Content-Type: image/$($ext.ToLower())",
        "",
        [System.Text.Encoding]::UTF8.GetString($imageBytes),
        "--$boundary--"
    ) -join "`r`n"
    
    $uploadHeaders = @{ 
        "Authorization" = "Basic $base64"
        "Content-Type"  = "multipart/form-data; boundary=$boundary"
    }
    
    try {
        Invoke-RestMethod -Uri "https://$DX80IP/api/v1/userinterface/presentation/background" `
            -Method Put -Headers $uploadHeaders -Body $bodyLines -TimeoutSec 30
        Write-Host "[OK] Hintergrundbild hochgeladen" -ForegroundColor Green
    }
    catch {
        Write-Warning "REST Upload gescheitert. Alternativ: DX80 Web UI -> Setup -> Personalization -> Wallpaper"
    }
}
else {
    Write-Host "[INFO] Kein Hintergrundbild angegeben." -ForegroundColor Yellow
    Write-Host "       Hochladen ueber: https://$DX80IP -> Setup -> Personalization -> Wallpaper"
}

# --- 2. Zweites SIP Profil (Multi-SIP) ---
if ($SIP2Rufnummer -and $SIP2Passwort) {
    Write-Host "`nKonfiguriere zweites SIP Profil ($SIP2Rufnummer)..."
    $xmlSIP2Headers = @{ "Authorization" = "Basic $base64"; "Content-Type" = "text/xml" }
    $sipURI2 = "${SIP2Rufnummer}@${SIP2Proxy}"
    
    $xmlSIP2 = @"
<Configuration>
  <SIP>
    <Profile item="2">
      <URI>${sipURI2}</URI>
      <DisplayName>${SIP2Rufnummer}</DisplayName>
      <Proxy item="1"><Address>${SIP2Proxy}</Address></Proxy>
      <Authentication item="1">
        <UserName>${SIP2Rufnummer}</UserName>
        <Password>${SIP2Passwort}</Password>
      </Authentication>
      <DefaultTransport>TCP</DefaultTransport>
    </Profile>
  </SIP>
</Configuration>
"@
    try {
        Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $xmlSIP2Headers -Body $xmlSIP2 -TimeoutSec 10 | Out-Null
        Write-Host "[OK] SIP Profil 2 gesetzt: $sipURI2" -ForegroundColor Green
    }
    catch { Write-Error "SIP Profil 2 Fehler: $_" }
}
else {
    Write-Host "[INFO] Kein zweites SIP Profil angegeben (Parameter: -SIP2Rufnummer, -SIP2Passwort)" -ForegroundColor Yellow
}

Write-Host "`n=== Fertig ===" -ForegroundColor Cyan
Write-Host "Dark Background: Hochladen via DX80 Web UI: https://$DX80IP -> Personalization" -ForegroundColor Yellow
