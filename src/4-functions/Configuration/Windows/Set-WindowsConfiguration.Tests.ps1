BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\App lifecycle\Progressbar.ps1'
    . '.\src\4-functions\Configuration\Windows\Tools\Assertions.ps1'
    . '.\src\4-functions\Configuration\Windows\Remove-Annoyances.ps1'
    . '.\src\4-functions\Configuration\Windows\Set-MalwareProtectionConfiguration.ps1'
    . '.\src\4-functions\Configuration\Windows\Set-PowerSchemeConfiguration.ps1'
    . '.\src\4-functions\Configuration\Windows\Set-BaselineConfiguration.ps1'
    . '.\src\4-functions\Configuration\Windows\Set-LocalisationConfiguration.ps1'
    . '.\src\4-functions\Configuration\Windows\Set-PerformanceConfiguration.ps1'
    . '.\src\4-functions\Configuration\Windows\Set-PersonalisationConfiguration.ps1'
    . '.\src\4-functions\Configuration\Windows\Set-PrivacyConfiguration.ps1'
    . '.\src\4-functions\Configuration\Windows\Set-SecurityConfiguration.ps1'

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    function New-TestCheckBox([Bool]$IsChecked) {
        $cb = New-Object Windows.Controls.CheckBox
        $cb.IsChecked = $IsChecked
        return $cb
    }

    Set-Variable -Option Constant TestCheckboxSecurityChecked (New-TestCheckBox -IsChecked $True)
    Set-Variable -Option Constant TestCheckboxPerformanceChecked (New-TestCheckBox -IsChecked $True)
    Set-Variable -Option Constant TestCheckboxBaselineChecked (New-TestCheckBox -IsChecked $True)
    Set-Variable -Option Constant TestCheckboxAnnoyancesChecked (New-TestCheckBox -IsChecked $True)
    Set-Variable -Option Constant TestCheckboxPrivacyChecked (New-TestCheckBox -IsChecked $True)
    Set-Variable -Option Constant TestCheckboxLocalisationChecked (New-TestCheckBox -IsChecked $True)
    Set-Variable -Option Constant TestCheckboxPersonalisationChecked (New-TestCheckBox -IsChecked $True)

    Set-Variable -Option Constant TestCheckboxSecurityUnchecked (New-TestCheckBox -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxPerformanceUnchecked (New-TestCheckBox -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxBaselineUnchecked (New-TestCheckBox -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxAnnoyancesUnchecked (New-TestCheckBox -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxPrivacyUnchecked (New-TestCheckBox -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxLocalisationUnchecked (New-TestCheckBox -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxPersonalisationUnchecked (New-TestCheckBox -IsChecked $False)
}

Describe 'Set-WindowsConfiguration' {
    BeforeEach {
        Mock Test-WindowsDebloatIsRunning {}
        Mock Test-OOShutUp10IsRunning {}
        Mock Write-LogWarning {}
        Mock New-Activity {}
        Mock Write-ActivityProgress {}
        Mock Remove-Annoyances {}
        Mock Set-MalwareProtectionConfiguration {}
        Mock Set-PowerSchemeConfiguration {}
        Mock Set-BaselineConfiguration {}
        Mock Set-LocalisationConfiguration {}
        Mock Set-PerformanceConfiguration {}
        Mock Set-PersonalisationConfiguration {}
        Mock Set-PrivacyConfiguration {}
        Mock Set-SecurityConfiguration {}
        Mock Write-ActivityCompleted {}
    }

    It 'Should apply checked configurations' {
        Set-WindowsConfiguration $TestCheckboxSecurityChecked `
            $TestCheckboxPerformanceChecked `
            $TestCheckboxBaselineChecked `
            $TestCheckboxAnnoyancesChecked `
            $TestCheckboxPrivacyChecked `
            $TestCheckboxLocalisationChecked `
            $TestCheckboxPersonalisationChecked

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 9
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 1
        Should -Invoke Set-SecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Set-PerformanceConfiguration -Exactly 1
        Should -Invoke Set-BaselineConfiguration -Exactly 1
        Should -Invoke Remove-Annoyances -Exactly 1
        Should -Invoke Set-PrivacyConfiguration -Exactly 1
        Should -Invoke Set-LocalisationConfiguration -Exactly 1
        Should -Invoke Set-PersonalisationConfiguration -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should not apply unchecked configurations' {
        Set-WindowsConfiguration $TestCheckboxSecurityUnchecked `
            $TestCheckboxPerformanceUnchecked `
            $TestCheckboxBaselineUnchecked `
            $TestCheckboxAnnoyancesUnchecked `
            $TestCheckboxPrivacyUnchecked `
            $TestCheckboxLocalisationUnchecked `
            $TestCheckboxPersonalisationUnchecked

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 0
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalisationConfiguration -Exactly 0
        Should -Invoke Set-PersonalisationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should exit if Windows debloat is running' {
        Mock Test-WindowsDebloatIsRunning { return @(@{ ProcessName = 'powershell' }) }

        Set-WindowsConfiguration $TestCheckboxSecurityChecked `
            $TestCheckboxPerformanceChecked `
            $TestCheckboxBaselineChecked `
            $TestCheckboxAnnoyancesChecked `
            $TestCheckboxPrivacyChecked `
            $TestCheckboxLocalisationChecked `
            $TestCheckboxPersonalisationChecked

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 2
        Should -Invoke New-Activity -Exactly 0
        Should -Invoke Write-ActivityProgress -Exactly 0
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalisationConfiguration -Exactly 0
        Should -Invoke Set-PersonalisationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should exit if OOShutUp10 is running' {
        Mock Test-OOShutUp10IsRunning { return @(@{ ProcessName = 'OOSU10' }) }

        Set-WindowsConfiguration $TestCheckboxSecurityChecked `
            $TestCheckboxPerformanceChecked `
            $TestCheckboxBaselineChecked `
            $TestCheckboxAnnoyancesChecked `
            $TestCheckboxPrivacyChecked `
            $TestCheckboxLocalisationChecked `
            $TestCheckboxPersonalisationChecked

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 2
        Should -Invoke New-Activity -Exactly 0
        Should -Invoke Write-ActivityProgress -Exactly 0
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalisationConfiguration -Exactly 0
        Should -Invoke Set-PersonalisationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Test-WindowsDebloatIsRunning failure' {
        Mock Test-WindowsDebloatIsRunning { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityChecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalisationUnchecked `
                $TestCheckboxPersonalisationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 0
        Should -Invoke Write-ActivityProgress -Exactly 0
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalisationConfiguration -Exactly 0
        Should -Invoke Set-PersonalisationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Test-OOShutUp10IsRunning failure' {
        Mock Test-OOShutUp10IsRunning { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityChecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalisationUnchecked `
                $TestCheckboxPersonalisationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 0
        Should -Invoke Write-ActivityProgress -Exactly 0
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalisationConfiguration -Exactly 0
        Should -Invoke Set-PersonalisationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-MalwareProtectionConfiguration failure' {
        Mock Set-MalwareProtectionConfiguration { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityChecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalisationUnchecked `
                $TestCheckboxPersonalisationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 1
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalisationConfiguration -Exactly 0
        Should -Invoke Set-PersonalisationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-SecurityConfiguration failure' {
        Mock Set-SecurityConfiguration { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityChecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalisationUnchecked `
                $TestCheckboxPersonalisationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 2
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 1
        Should -Invoke Set-SecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalisationConfiguration -Exactly 0
        Should -Invoke Set-PersonalisationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-PowerSchemeConfiguration failure' {
        Mock Set-PowerSchemeConfiguration { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityUnchecked `
                $TestCheckboxPerformanceChecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalisationUnchecked `
                $TestCheckboxPersonalisationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalisationConfiguration -Exactly 0
        Should -Invoke Set-PersonalisationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-PerformanceConfiguration failure' {
        Mock Set-PerformanceConfiguration { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityUnchecked `
                $TestCheckboxPerformanceChecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalisationUnchecked `
                $TestCheckboxPersonalisationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 2
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Set-PerformanceConfiguration -Exactly 1
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalisationConfiguration -Exactly 0
        Should -Invoke Set-PersonalisationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-BaselineConfiguration failure' {
        Mock Set-BaselineConfiguration { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityUnchecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineChecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalisationUnchecked `
                $TestCheckboxPersonalisationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 1
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalisationConfiguration -Exactly 0
        Should -Invoke Set-PersonalisationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Remove-Annoyances failure' {
        Mock Remove-Annoyances { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityUnchecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesChecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalisationUnchecked `
                $TestCheckboxPersonalisationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 1
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalisationConfiguration -Exactly 0
        Should -Invoke Set-PersonalisationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-PrivacyConfiguration failure' {
        Mock Set-PrivacyConfiguration { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityUnchecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyChecked `
                $TestCheckboxLocalisationUnchecked `
                $TestCheckboxPersonalisationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 1
        Should -Invoke Set-LocalisationConfiguration -Exactly 0
        Should -Invoke Set-PersonalisationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-LocalisationConfiguration failure' {
        Mock Set-LocalisationConfiguration { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityUnchecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalisationChecked `
                $TestCheckboxPersonalisationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalisationConfiguration -Exactly 1
        Should -Invoke Set-PersonalisationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-PersonalisationConfiguration failure' {
        Mock Set-PersonalisationConfiguration { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityUnchecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalisationUnchecked `
                $TestCheckboxPersonalisationChecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalisationConfiguration -Exactly 0
        Should -Invoke Set-PersonalisationConfiguration -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
