BeforeAll {
    # Untyped stubs so Pester can mock Windows-only commands on any host —
    # mocks and ParameterFilters bind against these simple parameters on every platform
    function Delete-DeliveryOptimizationCache { [CmdletBinding()] param([Switch]$Force) }

    # $env:SystemRoot only exists on Windows — pin it so the hardcoded path expectations hold everywhere
    if (-not $env:SystemRoot) { $env:SystemRoot = 'C:\Windows' }

    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\Common\types.ps1"
    . "$PSScriptRoot\..\Configuration\Windows\Tools\Assertions.ps1"
    . "$PSScriptRoot\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\..\App lifecycle\Progressbar.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_TEMP_DIR ([String]'TEST_PATH_TEMP_DIR\')
    Set-Variable -Option Constant PATH_APP_DIR ([String]"$($PATH_TEMP_DIR)qiiwexc")

    Set-Variable -Option Constant TestVolumeCachesKey ([String]'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches')
    Set-Variable -Option Constant TestVolumeCache1 ([PSObject]@{ PsPath = 'TEST_VOLUME_CACHE_1' })
    Set-Variable -Option Constant TestVolumeCache2 ([PSObject]@{ PsPath = 'TEST_VOLUME_CACHE_2' })

    Set-Variable -Option Constant TestAppDir ([PSCustomObject]@{ Name = 'qiiwexc'; FullName = $PATH_APP_DIR })
    Set-Variable -Option Constant TestTempFile ([PSCustomObject]@{ Name = 'TEST_TEMP_FILE'; FullName = "$($PATH_TEMP_DIR)TEST_TEMP_FILE" })
}

Describe 'Start-Cleanup' {
    BeforeAll {
        Mock Test-SdiIsRunning {}
        Mock Test-DownloadingWindowsUpdates {}
        Mock Test-InstallingWindowsUpdates {}
        Mock Test-WindowsDebloatIsRunning {}
        Mock Test-ActivatorIsRunning {}
        Mock Write-LogWarning {}
        Mock New-Activity {}
        Mock Write-ActivityProgress {}
        Mock Delete-DeliveryOptimizationCache {}
        Mock Out-Success {}
        Mock Remove-Item {}
        Mock Get-ChildItem { return @($TestVolumeCache1, $TestVolumeCache2) } -ParameterFilter { $Path -eq $TestVolumeCachesKey }
        Mock Get-ChildItem { return @($TestAppDir, $TestTempFile) } -ParameterFilter { $LiteralPath -eq $PATH_TEMP_DIR }
        Mock Remove-ItemProperty {}
        Mock New-ItemProperty {}
        Mock Start-Process {}
        Mock Write-ActivityCompleted {}
    }

    It 'Should run cleanup' {
        Start-Cleanup

        Should -Invoke Test-SdiIsRunning -Exactly 1
        Should -Invoke Test-DownloadingWindowsUpdates -Exactly 1
        Should -Invoke Test-InstallingWindowsUpdates -Exactly 1
        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-ActivatorIsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1 -ParameterFilter { $Message -match 'Recycle Bin.*previous Windows installation.*can be undone' }
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Delete-DeliveryOptimizationCache -Exactly 1
        Should -Invoke Delete-DeliveryOptimizationCache -Exactly 1 -ParameterFilter { $Force -eq $True }
        Should -Invoke Out-Success -Exactly 5
        Should -Invoke Remove-Item -Exactly 3
        Should -Invoke Remove-Item -Exactly 1 -ParameterFilter {
            $Path -eq 'C:\Windows\Temp\*' -and
            $Recurse -eq $True -and
            $Force -eq $True -and
            $ErrorAction -eq 'Ignore'
        }
        Should -Invoke Get-ChildItem -Exactly 1 -ParameterFilter {
            $LiteralPath -eq $PATH_TEMP_DIR -and
            $Force -eq $True
        }
        Should -Invoke Remove-Item -Exactly 1 -ParameterFilter {
            $LiteralPath -eq $TestTempFile.FullName -and
            $Recurse -eq $True -and
            $Force -eq $True -and
            $ErrorAction -eq 'Ignore'
        }
        Should -Invoke Remove-Item -Exactly 1 -ParameterFilter {
            $Path -eq 'C:\Windows\SoftwareDistribution\Download\*' -and
            $Recurse -eq $True -and
            $Force -eq $True -and
            $ErrorAction -eq 'Ignore'
        }
        Should -Invoke Get-ChildItem -Exactly 2 -ParameterFilter { $Path -eq $TestVolumeCachesKey }
        Should -Invoke Remove-ItemProperty -Exactly 4
        Should -Invoke Remove-ItemProperty -Exactly 2 -ParameterFilter {
            $Path -eq $TestVolumeCache1.PsPath -and
            $Name -eq 'StateFlags3224' -and
            $Force -eq $True -and
            $ErrorAction -eq 'Ignore'
        }
        Should -Invoke Remove-ItemProperty -Exactly 2 -ParameterFilter {
            $Path -eq $TestVolumeCache2.PsPath -and
            $Name -eq 'StateFlags3224' -and
            $Force -eq $True -and
            $ErrorAction -eq 'Ignore'
        }
        Should -Invoke New-ItemProperty -Exactly 24
        Should -Invoke New-ItemProperty -Exactly 1 -ParameterFilter {
            $Path -eq "$TestVolumeCachesKey\Temporary Files" -and
            $Name -eq 'StateFlags3224' -and
            $Force -eq $True -and
            $PropertyType -eq 'DWord' -and
            $Value -eq 2
        }
        Should -Invoke New-ItemProperty -Exactly 1 -ParameterFilter {
            $Path -eq "$TestVolumeCachesKey\Recycle Bin" -and
            $Name -eq 'StateFlags3224' -and
            $Force -eq $True -and
            $PropertyType -eq 'DWord' -and
            $Value -eq 2
        }
        Should -Invoke New-ItemProperty -Exactly 1 -ParameterFilter {
            $Path -eq "$TestVolumeCachesKey\Update Cleanup" -and
            $Name -eq 'StateFlags3224' -and
            $Force -eq $True -and
            $PropertyType -eq 'DWord' -and
            $Value -eq 2
        }
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq 'cleanmgr.exe' -and
            $ArgumentList -eq "/d $env:SystemDrive /sagerun:3224" -and
            $Wait -eq $True
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It "Should keep the app's own folder in the user temp folder" {
        Start-Cleanup

        Should -Invoke Remove-Item -Exactly 0 -ParameterFilter { $LiteralPath -eq $PATH_APP_DIR }
    }

    It 'Should remove the flags only once Disk Cleanup has finished' {
        [Collections.Generic.List[String]]$script:Order = @()
        Mock Start-Process { $script:Order.Add('cleanmgr') }
        Mock Remove-ItemProperty { $script:Order.Add('remove') }

        Start-Cleanup

        $script:Order | Should -BeExactly @('remove', 'remove', 'cleanmgr', 'remove', 'remove')
    }

    It 'Should exit while <Name>' -ForEach @(
        @{ Name = 'SDI is running'; Check = 'Test-SdiIsRunning'; ChecksMade = 1 }
        @{ Name = 'Windows Update is downloading'; Check = 'Test-DownloadingWindowsUpdates'; ChecksMade = 2 }
        @{ Name = 'Windows Update is installing'; Check = 'Test-InstallingWindowsUpdates'; ChecksMade = 3 }
        @{ Name = 'the Windows debloat utility is running'; Check = 'Test-WindowsDebloatIsRunning'; ChecksMade = 4 }
        @{ Name = 'the MAS activator is running'; Check = 'Test-ActivatorIsRunning'; ChecksMade = 5 }
    ) {
        Mock $Check { return @(@{ ProcessName = 'TEST_PROCESS' }) }

        Start-Cleanup

        [String[]]$Checks = @('Test-SdiIsRunning', 'Test-DownloadingWindowsUpdates', 'Test-InstallingWindowsUpdates', 'Test-WindowsDebloatIsRunning', 'Test-ActivatorIsRunning')
        for ([Int]$i = 0; $i -lt $Checks.Count; $i++) {
            Should -Invoke $Checks[$i] -Exactly ([Int]($i -lt $ChecksMade))
        }
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke New-Activity -Exactly 0
        Should -Invoke Delete-DeliveryOptimizationCache -Exactly 0
        Should -Invoke Remove-Item -Exactly 0
        Should -Invoke Get-ChildItem -Exactly 0
        Should -Invoke Remove-ItemProperty -Exactly 0
        Should -Invoke New-ItemProperty -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle <Check> failure' -ForEach @(
        @{ Check = 'Test-SdiIsRunning' }
        @{ Check = 'Test-DownloadingWindowsUpdates' }
        @{ Check = 'Test-InstallingWindowsUpdates' }
        @{ Check = 'Test-WindowsDebloatIsRunning' }
        @{ Check = 'Test-ActivatorIsRunning' }
    ) {
        Mock $Check { throw $TestException }

        { Start-Cleanup } | Should -Throw $TestException

        Should -Invoke $Check -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke New-Activity -Exactly 0
        Should -Invoke Remove-Item -Exactly 0
        Should -Invoke Start-Process -Exactly 0
    }

    It 'Should handle Delete-DeliveryOptimizationCache failure' {
        Mock Delete-DeliveryOptimizationCache { throw $TestException }

        { Start-Cleanup } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Delete-DeliveryOptimizationCache -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Remove-Item -Exactly 0
        Should -Invoke Get-ChildItem -Exactly 0
        Should -Invoke Remove-ItemProperty -Exactly 0
        Should -Invoke New-ItemProperty -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Remove-Item failure' {
        Mock Remove-Item { throw $TestException }

        { Start-Cleanup } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Delete-DeliveryOptimizationCache -Exactly 1
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Remove-Item -Exactly 1
        Should -Invoke Get-ChildItem -Exactly 0
        Should -Invoke Remove-ItemProperty -Exactly 0
        Should -Invoke New-ItemProperty -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Get-ChildItem failure' {
        Mock Get-ChildItem { throw $TestException } -ParameterFilter { $Path -eq $TestVolumeCachesKey }

        { Start-Cleanup } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Delete-DeliveryOptimizationCache -Exactly 1
        Should -Invoke Out-Success -Exactly 4
        Should -Invoke Remove-Item -Exactly 3
        Should -Invoke Get-ChildItem -Exactly 1 -ParameterFilter { $Path -eq $TestVolumeCachesKey }
        Should -Invoke Remove-ItemProperty -Exactly 0
        Should -Invoke New-ItemProperty -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Remove-ItemProperty failure' {
        Mock Remove-ItemProperty { throw $TestException }

        { Start-Cleanup } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Delete-DeliveryOptimizationCache -Exactly 1
        Should -Invoke Out-Success -Exactly 4
        Should -Invoke Remove-Item -Exactly 3
        Should -Invoke Get-ChildItem -Exactly 1 -ParameterFilter { $Path -eq $TestVolumeCachesKey }
        Should -Invoke Remove-ItemProperty -Exactly 1
        Should -Invoke New-ItemProperty -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    # The flags already set are removed even so, so that no later Disk Cleanup run picks them up
    It 'Should remove the flags when <Command> fails' -ForEach @(
        @{ Command = 'New-ItemProperty'; NewItemPropertyCalls = 1; StartProcessCalls = 0 }
        @{ Command = 'Start-Process'; NewItemPropertyCalls = 24; StartProcessCalls = 1 }
    ) {
        Mock $Command { throw $TestException }

        { Start-Cleanup } | Should -Throw $TestException

        Should -Invoke New-ItemProperty -Exactly $NewItemPropertyCalls
        Should -Invoke Start-Process -Exactly $StartProcessCalls
        Should -Invoke Get-ChildItem -Exactly 2 -ParameterFilter { $Path -eq $TestVolumeCachesKey }
        Should -Invoke Remove-ItemProperty -Exactly 4
        Should -Invoke Out-Success -Exactly 4
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
