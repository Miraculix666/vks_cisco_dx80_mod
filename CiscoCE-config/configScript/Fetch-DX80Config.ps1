[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls

$headers = @{"Authorization" = "Basic YWRtaW46" }
try {
    $response = Invoke-RestMethod -Uri "https://192.168.250.20/getxml?location=/Configuration" -Headers $headers -TimeoutSec 10
    $response.OuterXml | Out-File "DX80_Config.xml"
    Write-Host "Success"
}
catch {
    Write-Host "HTTPS failed: $_"
    try {
        $response = Invoke-RestMethod -Uri "http://192.168.250.20/getxml?location=/Configuration" -Headers $headers -TimeoutSec 10
        $response.OuterXml | Out-File "DX80_Config.xml"
        Write-Host "HTTP Success"
    }
    catch {
        Write-Host "HTTP failed: $_"
    }
}
