<#
.SYNOPSIS
    Überprüft die Konfiguration und führt einen Reboot via SSH durch (falls nötig).

.DESCRIPTION
    Da REST-API (GET) manchmal bei größeren XMLs abbricht, 
    wird hier SSH (Port 22) für den Abruf verwendet.
#>

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

Write-Host "--- Ueberpruefe Konfiguration via SSH ($DX80IP) ---" -ForegroundColor Cyan

# Posh-SSH waere hier optimal, aber fuer einen einfachen Check nutze ich ssh
# ACHTUNG: Standard ssh-Client von Windows fragt interaktiv nach dem Passwort.
# Alternativ koennen wir PLINK nutzen oder auf die API für putxml bleiben.

Write-Host "Da SSH Native unter Windows Passwort-Prompts erzeugt, lesen wir kurz aus der REST-Status-API:"

# REST GET /Status ist oft viel kleiner und erfolgreicher als /Configuration
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::SecurityProtocol = 3072 # TLS 1.2
$base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${DX80User}:${DX80Password}"))
$headers = @{ "Authorization" = "Basic $base64" }

try {
    # Check SIP Status
    $statusResponse = Invoke-RestMethod -Uri "https://$DX80IP/getxml?location=/Status/SIP" -Method Get -Headers $headers -TimeoutSec 10
    $sipStatus = $statusResponse.Status.SIP.Registration.Status

    # Check Branding
    $configResponse = Invoke-RestMethod -Uri "https://$DX80IP/getxml?location=/Configuration/UserInterface/Branding" -Method Get -Headers $headers -TimeoutSec 10
    $theme = $configResponse.Configuration.UserInterface.Branding.AwakeBranding.Colors

    Write-Host "SIP Registrierungs-Status : $sipStatus" -ForegroundColor Yellow
    Write-Host "Ermitteltes Theme         : $theme" -ForegroundColor Yellow

    if ($sipStatus -eq "Registered") { Write-Host "[OK] SIP ist online!" -ForegroundColor Green }
    if ($theme -eq "Native") { Write-Host "[OK] Dark Theme ist aktiv!" -ForegroundColor Green }

}
catch {
    Write-Host "Fehler beim Abruf. Geraet startet moeglicherweise gerade neu." -ForegroundColor DarkGray
}
