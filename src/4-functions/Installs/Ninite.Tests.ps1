BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    . '.\src\4-functions\Common\Open-InBrowser.ps1'
    . '.\src\4-functions\Common\Start-DownloadUnzipAndRun.ps1'

    function New-TestCheckBox([Bool]$IsChecked, [String]$Tag, [String]$Content) {
        $cb = New-Object Windows.Controls.CheckBox
        $cb.IsChecked = $IsChecked
        $cb.Tag = $Tag
        $cb.Content = $Content
        return $cb
    }

    Set-Variable -Option Constant TEST_CHECKBOX_1 (New-TestCheckBox -IsChecked $True -Tag 'TEST_CHECKBOX_1_NAME' -Content 'APP_NAME_1')
    Set-Variable -Option Constant TEST_CHECKBOX_2 (New-TestCheckBox -IsChecked $False -Tag 'TEST_CHECKBOX_2_NAME' -Content 'APP_NAME_2')
    Set-Variable -Option Constant TEST_CHECKBOX_3 (New-TestCheckBox -IsChecked $True -Tag 'TEST_CHECKBOX_3_NAME' -Content 'Install APP_NAME_3')

    Set-Variable -Option Constant TestCheckboxes (
        [Windows.Controls.CheckBox[]]@(
            $TEST_CHECKBOX_1,
            $TEST_CHECKBOX_2,
            $TEST_CHECKBOX_3
        )
    )

    Set-Variable -Option Constant TestQuery ([String]"$($TEST_CHECKBOX_1.Tag)-$($TEST_CHECKBOX_3.Tag)")
}

Describe 'Set-NiniteButtonState' {
    BeforeEach {
        Set-Variable -Option Constant CHECKBOX_StartNinite (& { $cb = New-Object Windows.Controls.CheckBox; $cb.IsEnabled = $False; $cb })
    }

    It 'Should enable the Ninite button when at least one checkbox is checked' {
        [Windows.Controls.CheckBox[]]$NINITE_CHECKBOXES =
        @(
            $TEST_CHECKBOX_1,
            $TEST_CHECKBOX_2,
            $TEST_CHECKBOX_3
        )

        Set-NiniteButtonState

        $CHECKBOX_StartNinite.IsEnabled | Should -BeTrue
    }

    It 'Should disable the Ninite button when no checkboxes are checked' {
        [Windows.Controls.CheckBox[]]$NINITE_CHECKBOXES =
        @(
            $TEST_CHECKBOX_2,
            $TEST_CHECKBOX_2
        )

        Set-NiniteButtonState

        $CHECKBOX_StartNinite.IsEnabled | Should -BeFalse
    }
}

Describe 'Get-NiniteInstaller' {
    BeforeEach {
        Mock Open-InBrowser {}
        Mock Start-DownloadUnzipAndRun {}
    }

    It 'Should open Ninite URL in browser' {
        Set-Variable -Option Constant TestOpenInBrowser ([Switch]$True)

        Get-NiniteInstaller $TestCheckboxes -OpenInBrowser:$TestOpenInBrowser

        Should -Invoke Open-InBrowser -Exactly 1
        Should -Invoke Open-InBrowser -Exactly 1 -ParameterFilter { $URL -eq "{URL_NINITE}/?select=$TestQuery" }
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 0
    }

    It 'Should download and run Ninite installer' {
        Set-Variable -Option Constant TestOpenInBrowser ([Switch]$False)

        Get-NiniteInstaller $TestCheckboxes -OpenInBrowser:$TestOpenInBrowser -Execute

        Should -Invoke Open-InBrowser -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq "{URL_NINITE}/$TestQuery/ninite.exe" -and
            $FileName -eq 'Ninite APP_NAME_1 Install APP_NAME_3 Installer.exe' -and
            $Execute -eq $True
        }
    }
}
