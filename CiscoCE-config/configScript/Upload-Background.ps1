# DX80 Hintergrundbild hochladen
param(
    [string]$DX80IP = "192.168.250.20",
    [string]$DX80User = "admin",
    [string]$DX80Pass = "",
    [string]$ImagePath = "C:\GitHub\vks_cisco_dx80_base\vks_cisco_dx80_mod\background.png"
)

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
$imgBytes = [System.IO.File]::ReadAllBytes($ImagePath)
$boundary = [System.Guid]::NewGuid().ToString("N")

$ms = New-Object System.IO.MemoryStream
$enc = [System.Text.Encoding]::Latin1
$hdr = "--${boundary}`r`nContent-Disposition: form-data; name=`"file`"; filename=`"background.png`"`r`nContent-Type: image/png`r`n`r`n"
$ftr = "`r`n--${boundary}--`r`n"
$hdrBytes = $enc.GetBytes($hdr)
$ftrBytes = $enc.GetBytes($ftr)
$ms.Write($hdrBytes, 0, $hdrBytes.Length)
$ms.Write($imgBytes, 0, $imgBytes.Length)
$ms.Write($ftrBytes, 0, $ftrBytes.Length)
$body = $ms.ToArray()

$headers = @{
    "Authorization" = "Basic $b64"
    "Content-Type"  = "multipart/form-data; boundary=$boundary"
}

# Endpunkte die beim DX80 funktionieren koennen:
$endpoints = @(
    "https://$DX80IP/web/background/set",
    "https://$DX80IP/api/v1/userinterface/presentation/background",
    "http://$DX80IP/web/background/set"
)

$success = $false
foreach ($url in $endpoints) {
    try {
        Write-Host "Versuche: $url" -ForegroundColor DarkCyan
        $resp = Invoke-WebRequest -Uri $url -Method Post -Headers $headers -Body $body -TimeoutSec 15 -ErrorAction Stop
        Write-Host "[OK] Hintergrundbild hochgeladen: $url (HTTP $($resp.StatusCode))" -ForegroundColor Green
        $success = $true
        break
    }
    catch {
        Write-Warning "  Fehlgeschlagen: $_"
    }
}

if (-not $success) {
    Write-Host "`n[INFO] Automatisches Upload nicht moeglich." -ForegroundColor Yellow
    Write-Host "  Manuell hochladen via: https://$DX80IP -> Setup -> Personalization -> Wallpaper"
}

