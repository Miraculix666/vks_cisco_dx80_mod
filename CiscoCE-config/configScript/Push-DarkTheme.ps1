# Cisco DX80 Dark Theme (ASCII/Safe Version)
# Fixed: Default User is "admin"

param(
  [string]$DX80IP = "192.168.250.20",
  [string]$DX80User = "admin",
  [string]$DX80Password = ""
)

. "$PSScriptRoot\DX80-Utils.ps1"

# --- Passwort-Logik ---
try {
    $DX80Password = & "$PSScriptRoot\..\configScript\Get-DX80Password.ps1" -ProvidedPassword $DX80Password
} catch {
    Write-Error $_
    return
}

$xmlPayload = @"
<Configuration>
  <UserInterface>
    <Branding><AwakeBranding><Colors>Native</Colors></AwakeBranding></Branding>
    <OSD><EncryptionIndicator>Off</EncryptionIndicator></OSD>
    <KeyTones><Mode>Off</Mode></KeyTones>
  </UserInterface>
</Configuration>
"@

Write-Host "--- Sende Dark Theme an $DX80IP (User: $DX80User) ---"
$result = Invoke-DX80RestMethod -IP $DX80IP -User $DX80User -Password $DX80Password -Path "putxml" -Body $xmlPayload
if ($result.Success) {
    Write-Host "Erfolgreich via $($result.Protocol)"
}
