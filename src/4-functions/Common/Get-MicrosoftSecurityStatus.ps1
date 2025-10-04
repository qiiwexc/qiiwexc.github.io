function Get-MicrosoftSecurityStatus {
    if ($PS_VERSION -ge 5) {
        Set-Variable -Option Constant Status (Get-MpComputerStatus)

        Set-Variable -Option Constant Properties (($Status | Get-Member -MemberType Property).Name)

        Set-Variable -Option Constant Filtered ($Properties | Where-Object { $_ -eq 'BehaviorMonitorEnabled' -or $_ -eq 'IoavProtectionEnabled' -or $_ -eq 'NISEnabled' -or $_ -eq 'OnAccessProtectionEnabled' -or $_ -eq 'RealTimeProtectionEnabled' })

        [Boolean]$IsEnabled = $False
        foreach ($Property in $Filtered) {
            if ($Status.$Property) {
                $IsEnabled = $True
            }
            break
        }

        return $IsEnabled
    }
}
