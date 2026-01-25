BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\App lifecycle\Progressbar.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
}

Describe 'Set-WindowsSecurityConfiguration' {
    BeforeEach {
        Mock Write-ActivityProgress {}
        Mock Set-MpPreference {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should apply Windows security configuration' {
        Set-WindowsSecurityConfiguration

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Set-MpPreference -Exactly 15
        Should -Invoke Set-MpPreference -Exactly 1 -ParameterFilter { $DisableBlockAtFirstSeen -eq $False }
        Should -Invoke Set-MpPreference -Exactly 1 -ParameterFilter { $DisableCatchupQuickScan -eq $False }
        Should -Invoke Set-MpPreference -Exactly 1 -ParameterFilter { $DisableEmailScanning -eq $False }
        Should -Invoke Set-MpPreference -Exactly 1 -ParameterFilter { $DisableRemovableDriveScanning -eq $False }
        Should -Invoke Set-MpPreference -Exactly 1 -ParameterFilter { $DisableRestorePoint -eq $False }
        Should -Invoke Set-MpPreference -Exactly 1 -ParameterFilter { $DisableScanningMappedNetworkDrivesForFullScan -eq $False }
        Should -Invoke Set-MpPreference -Exactly 1 -ParameterFilter { $DisableScanningNetworkFiles -eq $False }
        Should -Invoke Set-MpPreference -Exactly 1 -ParameterFilter { $EnableFileHashComputation -eq $True }
        Should -Invoke Set-MpPreference -Exactly 1 -ParameterFilter { $EnableNetworkProtection -eq 'Enabled' }
        Should -Invoke Set-MpPreference -Exactly 1 -ParameterFilter { $PUAProtection -eq 'Enabled' }
        Should -Invoke Set-MpPreference -Exactly 1 -ParameterFilter { $AllowSwitchToAsyncInspection -eq $True }
        Should -Invoke Set-MpPreference -Exactly 1 -ParameterFilter { $MeteredConnectionUpdates -eq $True }
        Should -Invoke Set-MpPreference -Exactly 1 -ParameterFilter { $IntelTDTEnabled -eq $True }
        Should -Invoke Set-MpPreference -Exactly 1 -ParameterFilter { $BruteForceProtectionLocalNetworkBlocking -eq $True }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Set-MpPreference failure' {
        Mock Set-MpPreference { throw $TestException }

        Set-WindowsSecurityConfiguration

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Set-MpPreference -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
