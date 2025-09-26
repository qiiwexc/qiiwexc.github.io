function Get-NetworkAdapter {
    return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True')
}

function Test-NetworkConnection {
    if (!(Get-NetworkAdapter)) {
        return 'Computer is not connected to the Internet'
    }
}
