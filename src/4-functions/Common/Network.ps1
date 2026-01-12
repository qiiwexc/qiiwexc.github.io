function Get-NetworkAdapter {
    return (Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True')
}

function Test-NetworkConnection {
    Set-Variable -Option Constant IsConnected ([Boolean](Get-NetworkAdapter))

    if (-not $IsConnected) {
        Write-LogError 'Computer is not connected to the Internet'
    }

    return $IsConnected
}
