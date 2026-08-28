param(
    [string]$ComPort = "COM5",
    [string]$BaudRate = "115200",
    [string[]]$Commands = @(
        "xConfiguration WebEngine Mode: On",
        "xConfiguration UserInterface WebEngine Mode: On",
        "xConfiguration UserInterface WebEngine Features URLBar: On",
        "xConfiguration Macros Mode: On"
    )
)

$cmdFile = "$env:TEMP\serial_cmds.txt"
$Commands -join "`n" | Out-File -FilePath $cmdFile -Encoding ascii -Force

Write-Host ">>> Sende Befehle via Serial ($ComPort)..." -ForegroundColor Cyan
# Wir nutzen plink im Batch-Modus
# -batch unterdrueckt interaktive Prompts
cmd.exe /c "plink.exe -serial $ComPort -sercfg $BaudRate,8,n,1,N < `"$cmdFile`""

Write-Host ">>> Done." -ForegroundColor Green
