BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Progressbar.ps1'
    . '.\src\4-functions\Configuration\Windows\Set-WindowsBaseConfiguration.ps1'
    . '.\src\4-functions\Configuration\Windows\Set-WindowsPersonalisationConfig.ps1'

    Add-Type -AssemblyName System.Windows.Forms

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestCheckboxBaseChecked ([Windows.Forms.CheckBox]@{ Checked = $True })
    Set-Variable -Option Constant TestCheckboxPersonalisationChecked ([Windows.Forms.CheckBox]@{ Checked = $True })
    Set-Variable -Option Constant TestCheckboxBaseUnchecked ([Windows.Forms.CheckBox]@{ Checked = $False })
    Set-Variable -Option Constant TestCheckboxPersonalisationUnchecked ([Windows.Forms.CheckBox]@{ Checked = $False })
}

Describe 'Set-WindowsConfiguration' {
    BeforeEach {
        Mock New-Activity {}
        Mock Set-WindowsBaseConfiguration {}
        Mock Set-WindowsPersonalisationConfig {}
        Mock Write-ActivityCompleted {}
    }

    It 'Should apply checked configurations' {
        Set-WindowsConfiguration $TestCheckboxBaseChecked $TestCheckboxPersonalisationChecked

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-WindowsBaseConfiguration -Exactly 1
        Should -Invoke Set-WindowsPersonalisationConfig -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should not apply unchecked configurations' {
        Set-WindowsConfiguration $TestCheckboxBaseUnchecked $TestCheckboxPersonalisationUnchecked
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-WindowsBaseConfiguration -Exactly 0
        Should -Invoke Set-WindowsPersonalisationConfig -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle Set-WindowsBaseConfiguration failure' {
        Mock Set-WindowsBaseConfiguration { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxBaseChecked $TestCheckboxPersonalisationUnchecked } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-WindowsBaseConfiguration -Exactly 1
        Should -Invoke Set-WindowsPersonalisationConfig -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-WindowsPersonalisationConfig failure' {
        Mock Set-WindowsPersonalisationConfig { throw $TestException }

        { Set-WindowsConfiguration $TestCheckboxBaseUnchecked $TestCheckboxPersonalisationChecked } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-WindowsBaseConfiguration -Exactly 0
        Should -Invoke Set-WindowsPersonalisationConfig -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
