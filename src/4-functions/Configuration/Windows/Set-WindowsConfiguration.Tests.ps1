#pester:no-parallel - builds WPF controls, which need an STA thread, and parallel workers are MTA

BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\..\..\App lifecycle\Progressbar.ps1"
    . "$PSScriptRoot\Tools\Assertions.ps1"
    . "$PSScriptRoot\Remove-Annoyances.ps1"
    . "$PSScriptRoot\Set-MalwareProtectionConfiguration.ps1"
    . "$PSScriptRoot\Set-PowerSchemeConfiguration.ps1"
    . "$PSScriptRoot\Set-BaselineConfiguration.ps1"
    . "$PSScriptRoot\Set-LocalizationConfiguration.ps1"
    . "$PSScriptRoot\Set-PerformanceConfiguration.ps1"
    . "$PSScriptRoot\Set-PersonalizationConfiguration.ps1"
    . "$PSScriptRoot\Set-PrivacyConfiguration.ps1"
    . "$PSScriptRoot\Set-SecurityConfiguration.ps1"

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
    Set-Variable -Option Constant TestCheckboxLocalizationChecked (New-TestCheckBox -IsChecked $True)
    Set-Variable -Option Constant TestCheckboxPersonalizationChecked (New-TestCheckBox -IsChecked $True)

    Set-Variable -Option Constant TestCheckboxSecurityUnchecked (New-TestCheckBox -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxPerformanceUnchecked (New-TestCheckBox -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxBaselineUnchecked (New-TestCheckBox -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxAnnoyancesUnchecked (New-TestCheckBox -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxPrivacyUnchecked (New-TestCheckBox -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxLocalizationUnchecked (New-TestCheckBox -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxPersonalizationUnchecked (New-TestCheckBox -IsChecked $False)
}

Describe 'Set-WindowsConfiguration' {
    BeforeAll {
        Mock Test-WindowsDebloatIsRunning {}
        Mock Test-OOShutUp10IsRunning {}
        Mock Write-LogWarning {}
        Mock New-Activity {}
        Mock Write-ActivityProgress {}
        Mock Remove-Annoyances {}
        Mock Set-MalwareProtectionConfiguration {}
        Mock Set-PowerSchemeConfiguration {}
        Mock Set-BaselineConfiguration {}
        Mock Set-LocalizationConfiguration {}
        Mock Set-PerformanceConfiguration {}
        Mock Set-PersonalizationConfiguration {}
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
            $TestCheckboxLocalizationChecked `
            $TestCheckboxPersonalizationChecked

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 1
        Should -Invoke Set-SecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Set-PerformanceConfiguration -Exactly 1
        Should -Invoke Set-BaselineConfiguration -Exactly 1
        Should -Invoke Remove-Annoyances -Exactly 1
        Should -Invoke Set-PrivacyConfiguration -Exactly 1
        Should -Invoke Set-LocalizationConfiguration -Exactly 1
        Should -Invoke Set-PersonalizationConfiguration -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should not apply unchecked configurations' {
        Set-WindowsConfiguration $TestCheckboxSecurityUnchecked `
            $TestCheckboxPerformanceUnchecked `
            $TestCheckboxBaselineUnchecked `
            $TestCheckboxAnnoyancesUnchecked `
            $TestCheckboxPrivacyUnchecked `
            $TestCheckboxLocalizationUnchecked `
            $TestCheckboxPersonalizationUnchecked

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalizationConfiguration -Exactly 0
        Should -Invoke Set-PersonalizationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should exit if Windows debloat is running' {
        Mock Test-WindowsDebloatIsRunning { return @(@{ ProcessName = 'powershell' }) }

        Set-WindowsConfiguration $TestCheckboxSecurityChecked `
            $TestCheckboxPerformanceChecked `
            $TestCheckboxBaselineChecked `
            $TestCheckboxAnnoyancesChecked `
            $TestCheckboxPrivacyChecked `
            $TestCheckboxLocalizationChecked `
            $TestCheckboxPersonalizationChecked

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 2
        Should -Invoke New-Activity -Exactly 0
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalizationConfiguration -Exactly 0
        Should -Invoke Set-PersonalizationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should exit if OOShutUp10 is running' {
        Mock Test-OOShutUp10IsRunning { return @(@{ ProcessName = 'OOSU10' }) }

        Set-WindowsConfiguration $TestCheckboxSecurityChecked `
            $TestCheckboxPerformanceChecked `
            $TestCheckboxBaselineChecked `
            $TestCheckboxAnnoyancesChecked `
            $TestCheckboxPrivacyChecked `
            $TestCheckboxLocalizationChecked `
            $TestCheckboxPersonalizationChecked

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 2
        Should -Invoke New-Activity -Exactly 0
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalizationConfiguration -Exactly 0
        Should -Invoke Set-PersonalizationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Test-WindowsDebloatIsRunning failure' {
        Mock Test-WindowsDebloatIsRunning { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityChecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalizationUnchecked `
                $TestCheckboxPersonalizationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 0
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalizationConfiguration -Exactly 0
        Should -Invoke Set-PersonalizationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Test-OOShutUp10IsRunning failure' {
        Mock Test-OOShutUp10IsRunning { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityChecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalizationUnchecked `
                $TestCheckboxPersonalizationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 0
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalizationConfiguration -Exactly 0
        Should -Invoke Set-PersonalizationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-BaselineConfiguration failure' {
        Mock Set-BaselineConfiguration { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityUnchecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineChecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalizationUnchecked `
                $TestCheckboxPersonalizationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 1
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalizationConfiguration -Exactly 0
        Should -Invoke Set-PersonalizationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-PrivacyConfiguration failure' {
        Mock Set-PrivacyConfiguration { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityUnchecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyChecked `
                $TestCheckboxLocalizationUnchecked `
                $TestCheckboxPersonalizationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 1
        Should -Invoke Set-LocalizationConfiguration -Exactly 0
        Should -Invoke Set-PersonalizationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-LocalizationConfiguration failure' {
        Mock Set-LocalizationConfiguration { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityUnchecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalizationChecked `
                $TestCheckboxPersonalizationUnchecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalizationConfiguration -Exactly 1
        Should -Invoke Set-PersonalizationConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-PersonalizationConfiguration failure' {
        Mock Set-PersonalizationConfiguration { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxSecurityUnchecked `
                $TestCheckboxPerformanceUnchecked `
                $TestCheckboxBaselineUnchecked `
                $TestCheckboxAnnoyancesUnchecked `
                $TestCheckboxPrivacyUnchecked `
                $TestCheckboxLocalizationUnchecked `
                $TestCheckboxPersonalizationChecked
        } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-SecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-PerformanceConfiguration -Exactly 0
        Should -Invoke Set-BaselineConfiguration -Exactly 0
        Should -Invoke Remove-Annoyances -Exactly 0
        Should -Invoke Set-PrivacyConfiguration -Exactly 0
        Should -Invoke Set-LocalizationConfiguration -Exactly 0
        Should -Invoke Set-PersonalizationConfiguration -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
