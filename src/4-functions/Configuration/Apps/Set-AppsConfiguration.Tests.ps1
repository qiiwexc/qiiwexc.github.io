BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Progressbar.ps1'
    . '.\src\4-functions\Configuration\Apps\Set-7zipConfiguration.ps1'
    . '.\src\4-functions\Configuration\Apps\Set-AnyDeskConfiguration.ps1'
    . '.\src\4-functions\Configuration\Apps\Set-GoogleChromeConfiguration.ps1'
    . '.\src\4-functions\Configuration\Apps\Set-MicrosoftEdgeConfiguration.ps1'
    . '.\src\4-functions\Configuration\Apps\Set-qBittorrentConfiguration.ps1'
    . '.\src\4-functions\Configuration\Apps\Set-VlcConfiguration.ps1'

    Add-Type -AssemblyName System.Windows.Forms

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestCheckbox7zipChecked (
        [Windows.Forms.CheckBox]@{
            Text    = '7zip'
            Checked = $True
        }
    )
    Set-Variable -Option Constant TestCheckboxVlcChecked (
        [Windows.Forms.CheckBox]@{
            Text    = 'VLC'
            Checked = $True
        }
    )
    Set-Variable -Option Constant TestCheckboxAnyDeskChecked (
        [Windows.Forms.CheckBox]@{
            Text    = 'AnyDesk'
            Checked = $True
        }
    )
    Set-Variable -Option Constant TestCheckboxqBittorrentChecked (
        [Windows.Forms.CheckBox]@{
            Text    = 'qBittorrent'
            Checked = $True
        }
    )
    Set-Variable -Option Constant TestCheckboxEdgeChecked (
        [Windows.Forms.CheckBox]@{
            Text    = 'Edge'
            Checked = $True
        }
    )
    Set-Variable -Option Constant TestCheckboxChromeChecked (
        [Windows.Forms.CheckBox]@{
            Text    = 'Chrome'
            Checked = $True
        }
    )
    Set-Variable -Option Constant TestCheckbox7zipUnchecked (
        [Windows.Forms.CheckBox]@{
            Text    = '7zip'
            Checked = $False
        }
    )
    Set-Variable -Option Constant TestCheckboxVlcUnchecked (
        [Windows.Forms.CheckBox]@{
            Text    = 'VLC'
            Checked = $False
        }
    )
    Set-Variable -Option Constant TestCheckboxAnyDeskUnchecked (
        [Windows.Forms.CheckBox]@{
            Text    = 'AnyDesk'
            Checked = $False
        }
    )
    Set-Variable -Option Constant TestCheckboxqBittorrentUnchecked (
        [Windows.Forms.CheckBox]@{
            Text    = 'qBittorrent'
            Checked = $False
        }
    )
    Set-Variable -Option Constant TestCheckboxEdgeUnchecked (
        [Windows.Forms.CheckBox]@{
            Text    = 'Edge'
            Checked = $False
        }
    )
    Set-Variable -Option Constant TestCheckboxChromeUnchecked (
        [Windows.Forms.CheckBox]@{
            Text    = 'Chrome'
            Checked = $False
        }
    )
}

Describe 'Set-AppsConfiguration' {
    BeforeEach {
        Mock New-Activity {}
        Mock Set-7zipConfiguration {}
        Mock Set-AnyDeskConfiguration {}
        Mock Set-GoogleChromeConfiguration {}
        Mock Set-MicrosoftEdgeConfiguration {}
        Mock Set-qBittorrentConfiguration {}
        Mock Set-VlcConfiguration {}
        Mock Write-ActivityCompleted {}
    }

    It 'Should configure checked apps' {
        Set-AppsConfiguration $TestCheckbox7zipChecked `
            $TestCheckboxVlcChecked `
            $TestCheckboxAnyDeskChecked `
            $TestCheckboxqBittorrentChecked `
            $TestCheckboxEdgeChecked `
            $TestCheckboxChromeChecked

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-7zipConfiguration -Exactly 1
        Should -Invoke Set-7zipConfiguration -Exactly 1 -ParameterFilter { $AppName -eq $TestCheckbox7zipChecked.Text }
        Should -Invoke Set-VlcConfiguration -Exactly 1
        Should -Invoke Set-VlcConfiguration -Exactly 1 -ParameterFilter { $AppName -eq $TestCheckboxVlcChecked.Text }
        Should -Invoke Set-AnyDeskConfiguration -Exactly 1
        Should -Invoke Set-AnyDeskConfiguration -Exactly 1 -ParameterFilter { $AppName -eq $TestCheckboxAnyDeskChecked.Text }
        Should -Invoke Set-qBittorrentConfiguration -Exactly 1
        Should -Invoke Set-qBittorrentConfiguration -Exactly 1 -ParameterFilter { $AppName -eq $TestCheckboxqBittorrentChecked.Text }
        Should -Invoke Set-MicrosoftEdgeConfiguration -Exactly 1
        Should -Invoke Set-MicrosoftEdgeConfiguration -Exactly 1 -ParameterFilter { $AppName -eq $TestCheckboxEdgeChecked.Text }
        Should -Invoke Set-GoogleChromeConfiguration -Exactly 1
        Should -Invoke Set-GoogleChromeConfiguration -Exactly 1 -ParameterFilter { $AppName -eq $TestCheckboxChromeChecked.Text }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should not configure unchecked apps' {
        Set-AppsConfiguration $TestCheckbox7zipUnchecked `
            $TestCheckboxVlcUnchecked `
            $TestCheckboxAnyDeskUnchecked `
            $TestCheckboxqBittorrentUnchecked `
            $TestCheckboxEdgeUnchecked `
            $TestCheckboxChromeUnchecked

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-7zipConfiguration -Exactly 0
        Should -Invoke Set-VlcConfiguration -Exactly 0
        Should -Invoke Set-AnyDeskConfiguration -Exactly 0
        Should -Invoke Set-qBittorrentConfiguration -Exactly 0
        Should -Invoke Set-MicrosoftEdgeConfiguration -Exactly 0
        Should -Invoke Set-GoogleChromeConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle Set-7zipConfiguration failure' {
        Mock Set-7zipConfiguration { throw $TestException }

        { Set-AppsConfiguration $TestCheckbox7zipChecked `
                $TestCheckboxVlcUnchecked `
                $TestCheckboxAnyDeskUnchecked `
                $TestCheckboxqBittorrentUnchecked `
                $TestCheckboxEdgeUnchecked `
                $TestCheckboxChromeUnchecked
        } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-7zipConfiguration -Exactly 1
        Should -Invoke Set-VlcConfiguration -Exactly 0
        Should -Invoke Set-AnyDeskConfiguration -Exactly 0
        Should -Invoke Set-qBittorrentConfiguration -Exactly 0
        Should -Invoke Set-MicrosoftEdgeConfiguration -Exactly 0
        Should -Invoke Set-GoogleChromeConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-VlcConfiguration failure' {
        Mock Set-VlcConfiguration { throw $TestException }

        { Set-AppsConfiguration $TestCheckbox7zipUnchecked `
                $TestCheckboxVlcChecked `
                $TestCheckboxAnyDeskUnchecked `
                $TestCheckboxqBittorrentUnchecked `
                $TestCheckboxEdgeUnchecked `
                $TestCheckboxChromeUnchecked
        } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-7zipConfiguration -Exactly 0
        Should -Invoke Set-VlcConfiguration -Exactly 1
        Should -Invoke Set-AnyDeskConfiguration -Exactly 0
        Should -Invoke Set-qBittorrentConfiguration -Exactly 0
        Should -Invoke Set-MicrosoftEdgeConfiguration -Exactly 0
        Should -Invoke Set-GoogleChromeConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-AnyDeskConfiguration failure' {
        Mock Set-AnyDeskConfiguration { throw $TestException }

        { Set-AppsConfiguration $TestCheckbox7zipUnchecked `
                $TestCheckboxVlcUnchecked `
                $TestCheckboxAnyDeskChecked `
                $TestCheckboxqBittorrentUnchecked `
                $TestCheckboxEdgeUnchecked `
                $TestCheckboxChromeUnchecked
        } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-7zipConfiguration -Exactly 0
        Should -Invoke Set-VlcConfiguration -Exactly 0
        Should -Invoke Set-AnyDeskConfiguration -Exactly 1
        Should -Invoke Set-qBittorrentConfiguration -Exactly 0
        Should -Invoke Set-MicrosoftEdgeConfiguration -Exactly 0
        Should -Invoke Set-GoogleChromeConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-qBittorrentConfiguration failure' {
        Mock Set-qBittorrentConfiguration { throw $TestException }

        { Set-AppsConfiguration $TestCheckbox7zipUnchecked `
                $TestCheckboxVlcUnchecked `
                $TestCheckboxAnyDeskUnchecked `
                $TestCheckboxqBittorrentChecked `
                $TestCheckboxEdgeUnchecked `
                $TestCheckboxChromeUnchecked
        } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-7zipConfiguration -Exactly 0
        Should -Invoke Set-VlcConfiguration -Exactly 0
        Should -Invoke Set-AnyDeskConfiguration -Exactly 0
        Should -Invoke Set-qBittorrentConfiguration -Exactly 1
        Should -Invoke Set-MicrosoftEdgeConfiguration -Exactly 0
        Should -Invoke Set-GoogleChromeConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-MicrosoftEdgeConfiguration failure' {
        Mock Set-MicrosoftEdgeConfiguration { throw $TestException }

        { Set-AppsConfiguration $TestCheckbox7zipUnchecked `
                $TestCheckboxVlcUnchecked `
                $TestCheckboxAnyDeskUnchecked `
                $TestCheckboxqBittorrentUnchecked `
                $TestCheckboxEdgeChecked `
                $TestCheckboxChromeUnchecked
        } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-7zipConfiguration -Exactly 0
        Should -Invoke Set-VlcConfiguration -Exactly 0
        Should -Invoke Set-AnyDeskConfiguration -Exactly 0
        Should -Invoke Set-qBittorrentConfiguration -Exactly 0
        Should -Invoke Set-MicrosoftEdgeConfiguration -Exactly 1
        Should -Invoke Set-GoogleChromeConfiguration -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-GoogleChromeConfiguration failure' {
        Mock Set-GoogleChromeConfiguration { throw $TestException }

        { Set-AppsConfiguration $TestCheckbox7zipUnchecked `
                $TestCheckboxVlcUnchecked `
                $TestCheckboxAnyDeskUnchecked `
                $TestCheckboxqBittorrentUnchecked `
                $TestCheckboxEdgeUnchecked `
                $TestCheckboxChromeChecked
        } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Set-7zipConfiguration -Exactly 0
        Should -Invoke Set-VlcConfiguration -Exactly 0
        Should -Invoke Set-AnyDeskConfiguration -Exactly 0
        Should -Invoke Set-qBittorrentConfiguration -Exactly 0
        Should -Invoke Set-MicrosoftEdgeConfiguration -Exactly 0
        Should -Invoke Set-GoogleChromeConfiguration -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
