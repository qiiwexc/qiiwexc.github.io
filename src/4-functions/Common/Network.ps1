function Get-NetworkAdapter {
    return (Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True')
}

function Test-NetworkConnection {
    if (-not (Get-NetworkAdapter)) {
        return 'Computer is not connected to the Internet'
    }
}
