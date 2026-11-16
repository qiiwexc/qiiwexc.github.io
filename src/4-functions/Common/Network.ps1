function Get-NetworkAdapter {
    return (Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True' -OperationTimeoutSec 15)
}

function Test-NetworkConnection {
    try {
        Set-Variable -Option Constant IsConnected ([Boolean](Get-NetworkAdapter))
    } catch [Microsoft.Management.Infrastructure.CimException] {
        if ($_.Exception.Message -match 'timeout|timed out') {
            Out-Failure 'Network check timed out'
        } else {
            Out-Failure "Network check failed: $_"
        }
        return $False
    } catch {
        Out-Failure "Network check failed: $_"
        return $False
    }

    if (-not $IsConnected) {
        Out-Failure 'Computer is not connected to the Internet'
        return $False
    }

    # Probe over HTTP rather than ICMP, which many networks filter: the request goes through the
    # system proxy like the downloads themselves, and a captive portal shows up as unexpected content.
    # The first is the endpoint Windows itself uses for its network connectivity indicator. A DNS
    # blocklist can include it, or answer for it with a page of its own, so a second, of another
    # company, has to fail as well before the connection counts as down
    Set-Variable -Option Constant Probes ([Hashtable[]]@(
            @{ Uri = 'http://www.msftconnecttest.com/connecttest.txt'; StatusCode = 200; Content = 'Microsoft Connect Test' },
            @{ Uri = 'http://cp.cloudflare.com/generate_204'; StatusCode = 204; Content = '' }
        )
    )

    [Bool]$Intercepted = $False
    foreach ($Probe in $Probes) {
        try {
            [PSObject]$Response = Invoke-WebRequest -Uri $Probe.Uri -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        } catch {
            Write-LogDebug "Connectivity probe $($Probe.Uri) failed: $_"
            continue
        }

        if ($Response.StatusCode -eq $Probe.StatusCode -and "$($Response.Content)" -eq $Probe.Content) {
            return $True
        }

        Write-LogDebug "Connectivity probe $($Probe.Uri) answered $($Response.StatusCode) with unexpected content"
        $Intercepted = $True
    }

    if ($Intercepted) {
        Out-Failure 'Internet access is restricted, a sign-in page may need to be completed first'
    } else {
        Out-Failure 'No Internet connectivity'
    }
    return $False
}
