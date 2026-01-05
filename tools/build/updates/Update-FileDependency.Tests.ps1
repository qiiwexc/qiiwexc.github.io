BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'
    . "$(Split-Path $PSCommandPath -Parent)\Set-NewVersion.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestWipPath ([String]'TEST_WIP_PATH')
    Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME')

    Set-Variable -Option Constant TestFilePath32 ([String]"$TestWipPath\$TestFileName x86.exe")
    Set-Variable -Option Constant TestFilePath64 ([String]"$TestWipPath\$TestFileName.exe")

    Set-Variable -Option Constant TestCurrentVersion ([String]'1.0.0')
    Set-Variable -Option Constant TestNewVersion ([String]'2.0.0')
    Set-Variable -Option Constant TestLatestVersion ([String]'3.0.0')

    Set-Variable -Option Constant TestDependency (
        [Object]@{
            name    = $TestFileName
            version = $TestCurrentVersion
        }
    )

    Set-Variable -Option Constant TypeDate (Get-TypeData -TypeName System.IO.FileInfo)
    Remove-TypeData -TypeData $TypeDate
    Set-Variable -Option Constant TypeBackup $TypeDate.Copy()
    $null = $TypeDate.members.Remove('VersionInfo')
    Update-TypeData -TypeData $TypeDate

    Set-Variable -Option Constant TestCurrentFile32bit (
        New-MockObject -Type System.IO.FileInfo -Properties @{ VersionInfo = @{ FileVersionRaw = $TestCurrentVersion } }
    )
    Set-Variable -Option Constant TestCurrentFile64bit (
        New-MockObject -Type System.IO.FileInfo -Properties @{ VersionInfo = @{ FileVersionRaw = $TestCurrentVersion } }
    )
    Set-Variable -Option Constant TestNewFile32bit (
        New-MockObject -Type System.IO.FileInfo -Properties @{ VersionInfo = @{ FileVersionRaw = $TestNewVersion } }
    )
    Set-Variable -Option Constant TestNewFile64bit (
        New-MockObject -Type System.IO.FileInfo -Properties @{ VersionInfo = @{ FileVersionRaw = $TestNewVersion } }
    )
    Set-Variable -Option Constant TestLatestFile32bit (
        New-MockObject -Type System.IO.FileInfo -Properties @{ VersionInfo = @{ FileVersionRaw = $TestLatestVersion } }
    )
    Set-Variable -Option Constant TestLatestFile64bit (
        New-MockObject -Type System.IO.FileInfo -Properties @{ VersionInfo = @{ FileVersionRaw = $TestLatestVersion } }
    )
}

AfterAll {
    Update-TypeData -TypeData $TypeBackup -Force
}

Describe 'Update-FileDependency' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Write-LogWarning {}
        Mock Set-NewVersion {}
        Mock Get-Item { return $TestNewFile32bit } -ParameterFilter { $Path -match ' x86.exe' }
        Mock Get-Item { return $TestNewFile64bit } -ParameterFilter { $Path -notmatch ' x86.exe' }
    }

    It 'Should update to new file version' {
        Update-FileDependency $TestDependency $TestWipPath | Should -BeNullOrEmpty

        Should -Invoke Write-LogInfo -Exactly 2
        Should -Invoke Get-Item -Exactly 2
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath64 }
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath32 }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency -eq $TestDependency -and
            $LatestVersion -eq $TestNewVersion
        }
    }

    It 'Should update to new file version when 32-bit file is newer' {
        Mock Get-Item { return $TestLatestFile32bit } -ParameterFilter { $Path -match ' x86.exe' }

        Update-FileDependency $TestDependency $TestWipPath | Should -BeNullOrEmpty

        Should -Invoke Write-LogInfo -Exactly 2
        Should -Invoke Get-Item -Exactly 2
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath64 }
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath32 }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency -eq $TestDependency -and
            $LatestVersion -eq $TestLatestVersion
        }
    }

    It 'Should update to new file version when 64-bit file is newer' {
        Mock Get-Item { return $TestLatestFile64bit } -ParameterFilter { $Path -notmatch ' x86.exe' }

        Update-FileDependency $TestDependency $TestWipPath | Should -BeNullOrEmpty

        Should -Invoke Write-LogInfo -Exactly 2
        Should -Invoke Get-Item -Exactly 2
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath64 }
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath32 }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency -eq $TestDependency -and
            $LatestVersion -eq $TestLatestVersion
        }
    }

    It 'Should not update if version is the same' {
        Mock Get-Item { return $TestCurrentFile32bit } -ParameterFilter { $Path -match ' x86.exe' }
        Mock Get-Item { return $TestCurrentFile64bit } -ParameterFilter { $Path -notmatch ' x86.exe' }

        Update-FileDependency $TestDependency $TestWipPath | Should -BeNullOrEmpty

        Should -Invoke Write-LogInfo -Exactly 2
        Should -Invoke Get-Item -Exactly 2
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath64 }
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath32 }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should update version and log warning if 32-bit file is missing' {
        Mock Get-Item { throw $TestException } -ParameterFilter { $Path -match ' x86.exe' }

        Update-FileDependency $TestDependency $TestWipPath | Should -BeNullOrEmpty

        Should -Invoke Write-LogInfo -Exactly 2
        Should -Invoke Get-Item -Exactly 2
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath64 }
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath32 }
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency -eq $TestDependency -and
            $LatestVersion -eq $TestNewVersion
        }
    }

    It 'Should update version and log warning if 64-bit file is missing' {
        Mock Get-Item { throw $TestException } -ParameterFilter { $Path -notmatch ' x86.exe' }

        Update-FileDependency $TestDependency $TestWipPath | Should -BeNullOrEmpty

        Should -Invoke Write-LogInfo -Exactly 2
        Should -Invoke Get-Item -Exactly 2
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath64 }
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath32 }
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency -eq $TestDependency -and
            $LatestVersion -eq $TestNewVersion
        }
    }

    It 'Should handle both files missing' {
        Mock Get-Item { throw $TestException } -ParameterFilter { $Path -match ' x86.exe' }
        Mock Get-Item { throw $TestException } -ParameterFilter { $Path -notmatch ' x86.exe' }

        Update-FileDependency $TestDependency $TestWipPath | Should -BeNullOrEmpty

        Should -Invoke Write-LogInfo -Exactly 2
        Should -Invoke Get-Item -Exactly 2
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath64 }
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath32 }
        Should -Invoke Write-LogWarning -Exactly 3
        Should -Invoke Set-NewVersion -Exactly 0
    }
}
