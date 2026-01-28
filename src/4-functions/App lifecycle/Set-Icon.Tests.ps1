BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\types.ps1'

    Set-Variable -Option Constant ICON_DEFAULT ([String]('ICON_DEFAULT'))
    Set-Variable -Option Constant ICON_CLEANUP ([String]('ICON_CLEANUP'))
    Set-Variable -Option Constant ICON_DOWNLOAD ([String]('ICON_DOWNLOAD'))
}

Describe 'Set-Icon' {
    BeforeEach {
        [Windows.Forms.Form]$FORM = New-MockObject -Type Windows.Forms.Form -Properties @{ Icon = 'ICON' }
    }

    It 'Should set default icon' {
        Set-Icon ([IconName]::Default)

        $FORM.Icon | Should -BeExactly $ICON_DEFAULT
    }

    It 'Should set cleanup icon' {
        Set-Icon ([IconName]::Cleanup)

        $FORM.Icon | Should -BeExactly $ICON_CLEANUP
    }

    It 'Should set download icon' {
        Set-Icon ([IconName]::Download)

        $FORM.Icon | Should -BeExactly $ICON_DOWNLOAD
    }

    It 'Should set default icon if icon name is omitted' {
        Set-Icon

        $FORM.Icon | Should -BeExactly $ICON_DEFAULT
    }
}
