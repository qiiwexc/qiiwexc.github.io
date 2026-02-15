BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Progressbar.ps1'
    . '.\src\4-functions\Configuration\Apps\Set-7zipConfiguration.ps1'
    . '.\src\4-functions\Configuration\Apps\Set-AnyDeskConfiguration.ps1'
    . '.\src\4-functions\Configuration\Apps\Set-GoogleChromeConfiguration.ps1'
    . '.\src\4-functions\Configuration\Apps\Set-MicrosoftEdgeConfiguration.ps1'
    . '.\src\4-functions\Configuration\Apps\Set-qBittorrentConfiguration.ps1'
    . '.\src\4-functions\Configuration\Apps\Set-VlcConfiguration.ps1'

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    function New-TestCheckBox([String]$Tag, [Bool]$IsChecked) {
        $cb = New-Object Windows.Controls.CheckBox
        $cb.Tag = $Tag
        $cb.IsChecked = $IsChecked
        return $cb
    }

    Set-Variable -Option Constant TestCheckbox7zipChecked (New-TestCheckBox -Tag '7zip' -IsChecked $True)
    Set-Variable -Option Constant TestCheckboxVlcChecked (New-TestCheckBox -Tag 'VLC' -IsChecked $True)
    Set-Variable -Option Constant TestCheckboxAnyDeskChecked (New-TestCheckBox -Tag 'AnyDesk' -IsChecked $True)
    Set-Variable -Option Constant TestCheckboxqBittorrentChecked (New-TestCheckBox -Tag 'qBittorrent' -IsChecked $True)
    Set-Variable -Option Constant TestCheckboxEdgeChecked (New-TestCheckBox -Tag 'Edge' -IsChecked $True)
    Set-Variable -Option Constant TestCheckboxChromeChecked (New-TestCheckBox -Tag 'Chrome' -IsChecked $True)

    Set-Variable -Option Constant TestCheckbox7zipUnchecked (New-TestCheckBox -Tag '7zip' -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxVlcUnchecked (New-TestCheckBox -Tag 'VLC' -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxAnyDeskUnchecked (New-TestCheckBox -Tag 'AnyDesk' -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxqBittorrentUnchecked (New-TestCheckBox -Tag 'qBittorrent' -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxEdgeUnchecked (New-TestCheckBox -Tag 'Edge' -IsChecked $False)
    Set-Variable -Option Constant TestCheckboxChromeUnchecked (New-TestCheckBox -Tag 'Chrome' -IsChecked $False)
}

Describe 'Set-AppsConfiguration' {
    BeforeEach {
        Mock New-Activity {}
        Mock Write-ActivityProgress {}
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
        Should -Invoke Write-ActivityProgress -Exactly 6
        Should -Invoke Set-7zipConfiguration -Exactly 1
        Should -Invoke Set-7zipConfiguration -Exactly 1 -ParameterFilter { $AppName -eq $TestCheckbox7zipChecked.Tag }
        Should -Invoke Set-VlcConfiguration -Exactly 1
        Should -Invoke Set-VlcConfiguration -Exactly 1 -ParameterFilter { $AppName -eq $TestCheckboxVlcChecked.Tag }
        Should -Invoke Set-AnyDeskConfiguration -Exactly 1
        Should -Invoke Set-AnyDeskConfiguration -Exactly 1 -ParameterFilter { $AppName -eq $TestCheckboxAnyDeskChecked.Tag }
        Should -Invoke Set-qBittorrentConfiguration -Exactly 1
        Should -Invoke Set-qBittorrentConfiguration -Exactly 1 -ParameterFilter { $AppName -eq $TestCheckboxqBittorrentChecked.Tag }
        Should -Invoke Set-MicrosoftEdgeConfiguration -Exactly 1
        Should -Invoke Set-MicrosoftEdgeConfiguration -Exactly 1 -ParameterFilter { $AppName -eq $TestCheckboxEdgeChecked.Tag }
        Should -Invoke Set-GoogleChromeConfiguration -Exactly 1
        Should -Invoke Set-GoogleChromeConfiguration -Exactly 1 -ParameterFilter { $AppName -eq $TestCheckboxChromeChecked.Tag }
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
        Should -Invoke Write-ActivityProgress -Exactly 0
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
        Should -Invoke Write-ActivityProgress -Exactly 1
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
        Should -Invoke Write-ActivityProgress -Exactly 1
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
        Should -Invoke Write-ActivityProgress -Exactly 1
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
        Should -Invoke Write-ActivityProgress -Exactly 1
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
        Should -Invoke Write-ActivityProgress -Exactly 1
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
        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Set-7zipConfiguration -Exactly 0
        Should -Invoke Set-VlcConfiguration -Exactly 0
        Should -Invoke Set-AnyDeskConfiguration -Exactly 0
        Should -Invoke Set-qBittorrentConfiguration -Exactly 0
        Should -Invoke Set-MicrosoftEdgeConfiguration -Exactly 0
        Should -Invoke Set-GoogleChromeConfiguration -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
