<#
.SYNOPSIS
Saves the complete configuration of the Cisco DX80 to a local file.

.DESCRIPTION
Connects to the Cisco DX80 via SSH and runs the 'xConfiguration' command. The output is captured and saved to DX80_Config.txt in the current directory. You will be prompted to enter the SSH password for the 'admin' user.
#>

$ipAddress = "192.168.250.20"
$username = "admin"
$outputFile = "DX80_Config.txt"

Write-Host "Connecting to Cisco DX80 at $ipAddress..."
Write-Host "Please enter the password for '$username' when prompted."
Write-Host ""

# Run SSH command and redirect output to file
ssh ${username}@${ipAddress} "xConfiguration" > $outputFile

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Configuration successfully saved to $outputFile" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Failed to save configuration. Please check your password and connection." -ForegroundColor Red
}
