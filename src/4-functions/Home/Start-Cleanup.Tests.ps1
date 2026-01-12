BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Progressbar.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_TEMP_DIR ([String]'TEST_PATH_TEMP_DIR')

    Set-Variable -Option Constant TestVolumeCache1 ([Object]@{ PsPath = 'TEST_VOLUME_CACHE_1' })
    Set-Variable -Option Constant TestVolumeCache2 ([Object]@{ PsPath = 'TEST_VOLUME_CACHE_2' })
}

Describe 'Start-Cleanup' {
    BeforeEach {
        Mock New-Activity { }
        Mock Write-ActivityProgress { }
        Mock Delete-DeliveryOptimizationCache { }
        Mock Out-Success { }
        Mock Write-ActivityProgress { }
        Mock Remove-Item { }
        Mock Get-ChildItem { return @($TestVolumeCache1, $TestVolumeCache2) }
        Mock Remove-ItemProperty { }
        Mock New-ItemProperty { }
        Mock Start-Process { }
        Mock Write-ActivityCompleted { }
    }

    It 'Should run cleanup' {
        Start-Cleanup

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 8
        Should -Invoke Delete-DeliveryOptimizationCache -Exactly 1
        Should -Invoke Delete-DeliveryOptimizationCache -Exactly 1 -ParameterFilter { $Force -eq $True }
        Should -Invoke Out-Success -Exactly 4
        Should -Invoke Out-Success -Exactly 4 -ParameterFilter { $Level -eq 1 }
        Should -Invoke Remove-Item -Exactly 3
        Should -Invoke Remove-Item -Exactly 1 -ParameterFilter {
            $Path -eq 'C:\Windows\Temp\*' -and
            $Recurse -eq $True -and
            $Force -eq $True -and
            $ErrorAction -eq 'Ignore'
        }
        Should -Invoke Remove-Item -Exactly 1 -ParameterFilter {
            $Path -eq "$PATH_TEMP_DIR\*" -and
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
        Should -Invoke Get-ChildItem -Exactly 2
        Should -Invoke Get-ChildItem -Exactly 2 -ParameterFilter { $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches' }
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
        Should -Invoke New-ItemProperty -Exactly 25
        Should -Invoke New-ItemProperty -Exactly 1 -ParameterFilter {
            $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -and
            $Name -eq 'StateFlags3224' -and
            $Force -eq $True -and
            $PropertyType -eq 'DWord' -and
            $Value -eq 2
        }
        Should -Invoke New-ItemProperty -Exactly 1 -ParameterFilter {
            $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin' -and
            $Name -eq 'StateFlags3224' -and
            $Force -eq $True -and
            $PropertyType -eq 'DWord' -and
            $Value -eq 2
        }
        Should -Invoke New-ItemProperty -Exactly 1 -ParameterFilter {
            $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup' -and
            $Name -eq 'StateFlags3224' -and
            $Force -eq $True -and
            $PropertyType -eq 'DWord' -and
            $Value -eq 2
        }
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq 'cleanmgr.exe' -and
            $ArgumentList -eq '/sagerun:3224'
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle Delete-DeliveryOptimizationCache failure' {
        Mock Delete-DeliveryOptimizationCache { throw $TestException }

        { Start-Cleanup } | Should -Throw

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 1
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

        { Start-Cleanup } | Should -Throw

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 2
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
        Mock Get-ChildItem { throw $TestException }

        { Start-Cleanup } | Should -Throw

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Delete-DeliveryOptimizationCache -Exactly 1
        Should -Invoke Out-Success -Exactly 4
        Should -Invoke Remove-Item -Exactly 3
        Should -Invoke Get-ChildItem -Exactly 1
        Should -Invoke Remove-ItemProperty -Exactly 0
        Should -Invoke New-ItemProperty -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Remove-ItemProperty failure' {
        Mock Remove-ItemProperty { throw $TestException }

        { Start-Cleanup } | Should -Throw

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Delete-DeliveryOptimizationCache -Exactly 1
        Should -Invoke Out-Success -Exactly 4
        Should -Invoke Remove-Item -Exactly 3
        Should -Invoke Get-ChildItem -Exactly 1
        Should -Invoke Remove-ItemProperty -Exactly 1
        Should -Invoke New-ItemProperty -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle New-ItemProperty failure' {
        Mock New-ItemProperty { throw $TestException }

        { Start-Cleanup } | Should -Throw

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 6
        Should -Invoke Delete-DeliveryOptimizationCache -Exactly 1
        Should -Invoke Out-Success -Exactly 4
        Should -Invoke Remove-Item -Exactly 3
        Should -Invoke Get-ChildItem -Exactly 1
        Should -Invoke Remove-ItemProperty -Exactly 2
        Should -Invoke New-ItemProperty -Exactly 1
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        { Start-Cleanup } | Should -Throw

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 7
        Should -Invoke Delete-DeliveryOptimizationCache -Exactly 1
        Should -Invoke Out-Success -Exactly 4
        Should -Invoke Remove-Item -Exactly 3
        Should -Invoke Get-ChildItem -Exactly 1
        Should -Invoke Remove-ItemProperty -Exactly 2
        Should -Invoke New-ItemProperty -Exactly 25
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
