# Cisco DX80 - Macro und UI Extensions Pusher
# Laedt das Macro (JS) und die UI Extensions (XML) auf das DX80 via REST API

param(
    [string]$DX80IP = "192.168.250.20",
    [string]$DX80User = "admin",
    [string]$DX80Password = ""
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
$headers = @{ "Authorization" = "Basic $base64"; "Content-Type" = "text/xml" }

function Push-XML {
    param([string]$label, [string]$xml)
    try {
        Invoke-RestMethod -Uri "https://$DX80IP/putxml" -Method Post -Headers $headers -Body $xml -TimeoutSec 10 | Out-Null
        Write-Host "[OK] $label" -ForegroundColor Green
    }
    catch {
        Write-Warning "[WARN] HTTPS fehlgeschlagen, versuche HTTP..."
        try {
            Invoke-RestMethod -Uri "http://$DX80IP/putxml" -Method Post -Headers $headers -Body $xml -TimeoutSec 10 | Out-Null
            Write-Host "[OK] $label (HTTP)" -ForegroundColor Green
        }
        catch { Write-Error "[FAIL] $label`: $_" }
    }
}

Write-Host "=== DX80 Macro & UI Push ===" -ForegroundColor Cyan

# --- 1. UI Extensions hochladen ---
$uiXmlPath = "$PSScriptRoot\vks_cisco_dx80_mod\MeetingShortcuts_UI.xml"
if (Test-Path $uiXmlPath) {
    $uiXmlContent = Get-Content $uiXmlPath -Raw -Encoding UTF8
    $uiPayload = @"
<Command>
  <UserInterface>
    <Extensions>
      <Set>
        <Panel>
          ${uiXmlContent}
        </Panel>
      </Set>
    </Extensions>
  </UserInterface>
</Command>
"@
    Push-XML "UI Extensions (Panels)" $uiPayload
}
else {
    Write-Warning "UI XML nicht gefunden: $uiXmlPath"
}

# --- 2. Macro Dateien hochladen ---
$macros = @(
    @{ Name = "MeetingShortcuts"; Path = "$PSScriptRoot\vks_cisco_dx80_mod\MeetingShortcuts.js" },
    @{ Name = "UsbWebcamPersistent"; Path = "$PSScriptRoot\vks_cisco_dx80_mod\UsbWebcamPersistent.js" }
)

foreach ($m in $macros) {
    if (Test-Path $m.Path) {
        $macroContent = Get-Content $m.Path -Raw -Encoding UTF8
        # Escape XML special chars
        $macroContent = $macroContent -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'
        $macroPayload = @"
<Command>
  <Macros>
    <Macro>
      <Save>
        <Name>$($m.Name)</Name>
        <Body>${macroContent}</Body>
        <Overwrite>True</Overwrite>
      </Save>
    </Macro>
  </Macros>
</Command>
"@
        Push-XML "Macro: $($m.Name).js" $macroPayload
    }
    else {
        Write-Warning "Macro nicht gefunden: $($m.Path)"
    }
}

# --- 3. Macros aktivieren ---
$xmlMacroOn = @"
<Configuration>
  <Macros><Mode>On</Mode></Macros>
  <Macros><AutoStart>On</AutoStart></Macros>
</Configuration>
"@
Push-XML "Macros Mode On + AutoStart" $xmlMacroOn

# --- 4. Macro starten ---
$startPayload = @"
<Command>
  <Macros>
    <Runtime>
      <Restart/>
    </Runtime>
  </Macros>
</Command>
"@
Push-XML "Macro Runtime Neustart" $startPayload

Write-Host "`n=== Fertig! Buttons sollten jetzt auf dem Bildschirm erscheinen. ===" -ForegroundColor Cyan

