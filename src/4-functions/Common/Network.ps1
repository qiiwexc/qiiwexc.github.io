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
    }

    return $IsConnected
}
