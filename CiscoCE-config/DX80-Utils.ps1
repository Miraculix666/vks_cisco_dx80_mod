function Invoke-DX80RestMethod {
    param(
        [Parameter(Mandatory=$true)]
        [string]$IP,

        [Parameter(Mandatory=$true)]
        [string]$User,

        [Parameter(Mandatory=$true)]
        [string]$Password,

        [Parameter(Mandatory=$true)]
        [string]$Path,

        [string]$Method = "Post",

        [string]$Body = "",

        [string]$ContentType = "text/xml",

        [int]$TimeoutSec = 10,

        [hashtable]$AdditionalHeaders = @{}
    )

    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    [System.Net.ServicePointManager]::SecurityProtocol = 3072 # TLS 1.2

    $base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${User}:${Password}"))
    $headers = @{
        "Authorization" = "Basic $base64"
    }

    if ($ContentType) {
        $headers["Content-Type"] = $ContentType
    }

    foreach ($key in $AdditionalHeaders.Keys) {
        $headers[$key] = $AdditionalHeaders[$key]
    }

    $httpsUri = "https://$IP/$Path"
    $httpUri = "http://$IP/$Path"

    try {
        $r = Invoke-RestMethod -Uri $httpsUri -Method $Method -Headers $headers -Body $Body -TimeoutSec $TimeoutSec
        return @{ Success = $true; Protocol = "HTTPS"; Response = $r }
    }
    catch {
        try {
            $r = Invoke-RestMethod -Uri $httpUri -Method $Method -Headers $headers -Body $Body -TimeoutSec $TimeoutSec
            return @{ Success = $true; Protocol = "HTTP"; Response = $r }
        }
        catch {
            Write-Error "Fehler: $_"
            return @{ Success = $false; Error = $_ }
        }
    }
}
