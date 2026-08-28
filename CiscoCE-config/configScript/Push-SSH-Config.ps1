# Cisco DX80 SSH Konfigurator (Plink Final Version)

# Load configuration from JSON
$configPath = Join-Path -Path $PSScriptRoot -ChildPath "config.template.json"
$config = Get-Content -Path $configPath | ConvertFrom-Json

$DX80IP = $config.DX80IP
$DX80User = $config.DX80User
$DX80Password = $config.DX80Password

$sipProxy = if ($config.TelekomAnschlussart -eq "Privat") { "tel.t-online.de" } else { "sip-trunk.telekom.de" }
$sipURITelekom = "$($config.TelekomRufnummer)@$sipProxy"

$sipURIFonial1 = "$($config.Rufnummer1)@$($config.FonialProxy)"
$sipURIFonial2 = "$($config.Rufnummer2)@$($config.FonialProxy)"
$sipURIFonial3 = "$($config.Rufnummer3)@$($config.FonialProxy)"

$commands = @(
    "echo off",
    "xConfiguration Network 1 IPv4 Assignment: Static",
    "xConfiguration Provisioning Mode: Edge",
    "xConfiguration UserInterface FirstTimeWizard: Off",
    "xConfiguration SystemUnit CrashReporting: Off",
    "xConfiguration Standby Halfwake: Off",
    "xConfiguration Proximity Mode: Off",
    "xConfiguration UserInterface Features JoinWebex: Hidden",
    "xConfiguration Provisioning ExternalManager Address: """" ",
    "xConfiguration Provisioning ExternalManager AlternateAddress: """" ",
    "xConfiguration WebEngine Mode: On",
    "xConfiguration Macros Mode: On",
    "xConfiguration UserInterface Features HideAll: False",
    "xConfiguration UserInterface Branding AwakeBranding Colors: Native",
    "xConfiguration UserInterface OSD EncryptionIndicator: Off",
    "xConfiguration SIP Profile 1 URI: $sipURITelekom",
    "xConfiguration SIP Profile 1 Proxy 1 Address: $sipProxy",
    "xConfiguration SIP Profile 1 Authentication 1 UserName: $($config.TelekomRufnummer)",
    "xConfiguration SIP Profile 1 Authentication 1 Password: $($config.TelekomSIPPasswort)",
    "xConfiguration SIP Profile 1 DefaultTransport: TCP",
    "xConfiguration SIP Profile 2 URI: $sipURIFonial1",
    "xConfiguration SIP Profile 2 Proxy 1 Address: $($config.FonialProxy)",
    "xConfiguration SIP Profile 2 Authentication 1 UserName: $($config.FonialUser)",
    "xConfiguration SIP Profile 2 Authentication 1 Password: $($config.FonialPasswort)",
    "xConfiguration SIP Profile 2 DefaultTransport: TCP",
    "xConfiguration SIP Profile 3 URI: $sipURIFonial2",
    "xConfiguration SIP Profile 3 Proxy 1 Address: $($config.FonialProxy)",
    "xConfiguration SIP Profile 3 Authentication 1 UserName: $($config.FonialUser)",
    "xConfiguration SIP Profile 3 Authentication 1 Password: $($config.FonialPasswort)",
    "xConfiguration SIP Profile 3 DefaultTransport: TCP",
    "xConfiguration SIP Profile 4 URI: $sipURIFonial3",
    "xConfiguration SIP Profile 4 Proxy 1 Address: $($config.FonialProxy)",
    "xConfiguration SIP Profile 4 Authentication 1 UserName: $($config.FonialUser)",
    "xConfiguration SIP Profile 4 Authentication 1 Password: $($config.FonialPasswort)",
    "xConfiguration SIP Profile 4 DefaultTransport: TCP",
    "xConfiguration NetworkServices SIP Mode: On",
    "xCommand SystemUnit Boot Action: Restart",
    "bye"
)

$cmdFile = "$env:TEMP\dx80_cmds.txt"
$commands -join "`n" | Out-File -FilePath $cmdFile -Encoding ascii -Force
Write-Host ">>> Befehle in $cmdFile geschrieben."

# 1. Key mit Plink akzeptieren (falls noetig)
cmd.exe /c "echo y | plink.exe -ssh ${DX80User}@${DX80IP} -pw `"${DX80Password}`" exit 2>nul"

# 2. Senden via plink
Write-Host ">>> Sende Befehle..."
cmd.exe /c "plink.exe -ssh ${DX80User}@${DX80IP} -pw `"${DX80Password}`" -m `"$cmdFile`""

Write-Host ">>> Done."
