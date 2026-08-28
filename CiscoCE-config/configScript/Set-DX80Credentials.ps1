# Speichert das DX80 Admin-Passwort sicher (ASCII/Safe Version)

param(
    [Parameter(Mandatory = $true)]
    [string]$Password
)

$credPath = "$HOME\.dx80_creds.xml"

try {
    $Password | ConvertTo-SecureString -AsPlainText -Force | Export-Clixml -Path $credPath
    Write-Host "Passwort sicher unter $credPath gespeichert."
}
catch {
    Write-Error "Fehler beim Speichern: $_"
}
