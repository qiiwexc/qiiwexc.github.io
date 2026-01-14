BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName System.Windows.Forms

    . '.\src\4-functions\Common\Open-InBrowser.ps1'
    . '.\src\4-functions\Common\Start-DownloadUnzipAndRun.ps1'

    Set-Variable -Option Constant TEST_CHECKBOX_1 (
        [Windows.Forms.CheckBox]@{
            Checked = $True
            Name    = 'TEST_CHECKBOX_1_NAME'
            Text    = 'TEST_CHECKBOX_1_TEXT'
        }
    )

    Set-Variable -Option Constant TEST_CHECKBOX_2 (
        [Windows.Forms.CheckBox]@{
            Checked = $False
            Name    = 'TEST_CHECKBOX_2_NAME'
            Text    = 'TEST_CHECKBOX_2_TEXT'
        }
    )

    Set-Variable -Option Constant TEST_CHECKBOX_3 (
        [Windows.Forms.CheckBox]@{
            Checked = $True
            Name    = 'TEST_CHECKBOX_3_NAME'
            Text    = 'TEST_CHECKBOX_3_TEXT'
        }
    )

    Set-Variable -Option Constant TestQuery ([String]"$($TEST_CHECKBOX_1.Name)-$($TEST_CHECKBOX_3.Name)")
}

Describe 'Set-NiniteButtonState' {
    BeforeEach {
        Set-Variable -Option Constant CHECKBOX_StartNinite ([Windows.Forms.CheckBox]@{ Enabled = $False })
    }

    It 'Should enable the Ninite button when at least one checkbox is checked' {
        [Collections.Generic.List[Windows.Forms.CheckBox]]$NINITE_CHECKBOXES =
        @(
            $TEST_CHECKBOX_1,
            $TEST_CHECKBOX_2,
            $TEST_CHECKBOX_3
        )

        Set-NiniteButtonState

        $CHECKBOX_StartNinite.Enabled | Should -BeTrue
    }

    It 'Should disable the Ninite button when no checkboxes are checked' {
        [Collections.Generic.List[Windows.Forms.CheckBox]]$NINITE_CHECKBOXES =
        @(
            $TEST_CHECKBOX_2,
            $TEST_CHECKBOX_2
        )

        Set-NiniteButtonState

        $CHECKBOX_StartNinite.Enabled | Should -BeFalse
    }
}

Describe 'Get-NiniteInstaller' {
    BeforeEach {
        Set-Variable -Option Constant NINITE_CHECKBOXES (
            [Collections.Generic.List[Windows.Forms.CheckBox]]@(
                $TEST_CHECKBOX_1,
                $TEST_CHECKBOX_2,
                $TEST_CHECKBOX_3
            )
        )

        Set-Variable -Option Constant TestExecute ([Switch]$True)

        Mock Open-InBrowser {}
        Mock Start-DownloadUnzipAndRun {}
    }

    It 'Should open Ninite URL in browser' {
        Set-Variable -Option Constant TestOpenInBrowser ([Switch]$True)

        Get-NiniteInstaller -OpenInBrowser:$TestOpenInBrowser

        Should -Invoke Open-InBrowser -Exactly 1
        Should -Invoke Open-InBrowser -Exactly 1 -ParameterFilter { $URL -eq "{URL_NINITE}/?select=$TestQuery" }
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 0
    }

    It 'Should download and run Ninite installer' {
        Set-Variable -Option Constant TestOpenInBrowser ([Switch]$False)

        Get-NiniteInstaller -OpenInBrowser:$TestOpenInBrowser -Execute:$TestExecute

        Should -Invoke Open-InBrowser -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq "{URL_NINITE}/$TestQuery/ninite.exe" -and
            $FileName -eq "Ninite $($TEST_CHECKBOX_1.Text) $($TEST_CHECKBOX_3.Text) Installer.exe" -and
            $Execute -eq $TestExecute
        }
    }
}
