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
    # This is the endpoint Windows itself uses for its network connectivity indicator.
    try {
        Set-Variable -Option Constant Response ([PSObject](Invoke-WebRequest -Uri 'http://www.msftconnecttest.com/connecttest.txt' -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop))
    } catch {
        Out-Failure 'No Internet connectivity'
        return $False
    }

    if ($Response.Content -ne 'Microsoft Connect Test') {
        Out-Failure 'Internet access is restricted, a sign-in page may need to be completed first'
        return $False
    }

    return $True
}
