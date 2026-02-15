BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\types.ps1'

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase
    Add-Type -AssemblyName System.Drawing

    Set-Variable -Option Constant DefaultIcon ([Drawing.SystemIcons]::Application)
    Set-Variable -Option Constant WorkingIcon ([Drawing.SystemIcons]::Information)

    Set-Variable -Option Constant ICON_DEFAULT $DefaultIcon
    Set-Variable -Option Constant ICON_WORKING $WorkingIcon
}

Describe 'Set-Icon' {
    BeforeEach {
        $FORM = [PSCustomObject]@{ Icon = $Null }
        $FORM | Add-Member -MemberType NoteProperty -Name Dispatcher -Value ([PSCustomObject]@{})
        $FORM.Dispatcher | Add-Member -MemberType ScriptMethod -Name CheckAccess -Value { return $true }
    }

    It 'Should set default icon' {
        Set-Icon ([IconName]::Default)

        $FORM.Icon | Should -Not -BeNullOrEmpty
        $FORM.Icon | Should -BeOfType [Windows.Media.Imaging.BitmapSource]
    }

    It 'Should set working icon' {
        Set-Icon ([IconName]::Working)

        $FORM.Icon | Should -Not -BeNullOrEmpty
        $FORM.Icon | Should -BeOfType [Windows.Media.Imaging.BitmapSource]
    }

    It 'Should set different icons for default and working' {
        Set-Icon ([IconName]::Default)
        Set-Variable -Option Constant DefaultResult $FORM.Icon

        Set-Icon ([IconName]::Working)
        Set-Variable -Option Constant WorkingResult $FORM.Icon

        $DefaultResult | Should -Not -BeExactly $WorkingResult
    }

    It 'Should set default icon if icon name is omitted' {
        Set-Icon

        $FORM.Icon | Should -Not -BeNullOrEmpty
        $FORM.Icon | Should -BeOfType [Windows.Media.Imaging.BitmapSource]
    }
}
