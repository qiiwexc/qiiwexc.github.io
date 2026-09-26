BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\common\logger.ps1"
    . "$PSScriptRoot\..\common\Progressbar.ps1"
    . "$PSScriptRoot\..\common\Read-TextFile.ps1"
    . "$PSScriptRoot\..\common\Write-TextFile.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestProjectName ([String]'TEST_PROJECT_NAME')
    Set-Variable -Option Constant TestPs1FilePath ([String]'TEST_PS1_FILE_PATH')
    Set-Variable -Option Constant TestBatchFilePath ([String]'TEST_BATCH_FILE_PATH')
    Set-Variable -Option Constant TestVmPath ([String]'TEST_VM_PATH')

    Set-Variable -Option Constant TestPs1FileContent ([String]"TEST_PS1_FILE_CONTENT_1`nTEST_PS1_FILE_CONTENT_2")

    Set-Variable -Option Constant TestVmBatchFilePath ([String]"$TestVmPath\$TestProjectName.bat")
}

Describe 'New-BatchScript' {
    BeforeAll {
        Mock New-Activity {}
        Mock Write-LogInfo {}
        Mock Read-TextFile { return $TestPs1FileContent }
        Mock Write-TextFile {}
        Mock Copy-Item {}
        Mock Write-ActivityCompleted {}
    }

    It 'Should create batch script' {
        New-BatchScript $TestProjectName $TestPs1FilePath $TestBatchFilePath $TestVmPath

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestPs1FilePath }
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestBatchFilePath -and
            $Content -match '@echo off' -and
            $Content -match "set `"psfile=%temp%\\$TestProjectName\.ps1`"" -and
            $Content -match 'set "batfile=%~f0"' -and
            $Content -match 'set "workdir=%~dp0"' -and
            $Content -match "Get-Content -LiteralPath \`$env:batfile -Encoding UTF8 \| Where-Object \{ \`$_\.StartsWith\('::'\) \}" -and
            $Content -match "Set-Content -LiteralPath \`$env:psfile -Encoding UTF8" -and
            $Content -match '  powershell -NoProfile -ExecutionPolicy Bypass -Command ' -and
            $Content -notmatch 'powershell -ExecutionPolicy' -and
            $Content -match "-WorkingDirectory \`$env:workdir\.TrimEnd\('\\'\)" -and
            $Content -notmatch '%cd%' -and
            $Content -notmatch "'%" -and
            $Content -match '::TEST_PS1_FILE_CONTENT_1' -and
            $Content -match '::TEST_PS1_FILE_CONTENT_2' -and
            $Content -notmatch 'enabledelayedexpansion'
        }
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Copy-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestBatchFilePath -and
            $Destination -eq $TestVmBatchFilePath
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should preserve exclamation marks in the bundled content without corruption' {
        Mock Read-TextFile { return "Write-Host 'oops!'" }

        New-BatchScript $TestProjectName $TestPs1FilePath $TestBatchFilePath $TestVmPath

        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            $Content -match "::Write-Host 'oops!'" -and
            $Content -notmatch 'enabledelayedexpansion'
        }
    }

    It 'Should handle Read-TextFile failure' {
        Mock Read-TextFile { throw $TestException }

        { New-BatchScript $TestProjectName $TestPs1FilePath $TestBatchFilePath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Write-TextFile failure' {
        Mock Write-TextFile { throw $TestException }

        { New-BatchScript $TestProjectName $TestPs1FilePath $TestBatchFilePath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Copy-Item failure' {
        Mock Copy-Item { throw $TestException }

        { New-BatchScript $TestProjectName $TestPs1FilePath $TestBatchFilePath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle empty PowerShell content' {
        Mock Read-TextFile { return '' }

        New-BatchScript $TestProjectName $TestPs1FilePath $TestBatchFilePath $TestVmPath

        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }
}

# Runs a generated launcher for real: cmd parses it, then PowerShell extracts and starts the embedded script.
# The launcher folder and %TEMP% carry the characters that used to break the quoting
Describe 'New-BatchScript launcher' -Skip:([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    BeforeAll {
        Mock New-Activity {}
        Mock Write-LogInfo {}
        Mock Write-ActivityCompleted {}

        Set-Variable -Option Constant LauncherDir ([String]"$TestDrive\O'Brien (Home) dir")
        Set-Variable -Option Constant TempDir ([String]"$TestDrive\temp O'Hara")
        Set-Variable -Option Constant MarkerFile ([String]"$TestDrive\marker.txt")
        Set-Variable -Option Constant PayloadFile ([String]"$TestDrive\payload.ps1")

        $Null = New-Item -ItemType Directory $LauncherDir, $TempDir, "$TestDrive\vm"

        # Stands in for the app: records the arguments the launcher started it with
        Set-Content -LiteralPath $PayloadFile -Encoding UTF8 -Value @(
            'param([String]$WorkingDirectory, [Switch]$DevMode)'
            "Add-Content -LiteralPath '$MarkerFile' `"`$WorkingDirectory|`$DevMode`""
        )

        New-BatchScript 'qiiwexc' $PayloadFile "$LauncherDir\qiiwexc.bat" "$TestDrive\vm"

        # %TEMP% is changed in the launcher's own cmd only: changed here, it would be changed for the whole
        # process, and so for every test file running in parallel, whose TestDrive Pester puts in %TEMP%
        Set-Variable -Option Constant SetTempDir ([String]"set `"TEMP=$TempDir`" && set `"TMP=$TempDir`" &&")
    }

    It 'Should extract the script to %TEMP% and start it in the launcher folder' {
        Start-Process cmd.exe -ArgumentList '/c', "$SetTempDir `"$LauncherDir\qiiwexc.bat`"" -WorkingDirectory $TestDrive -Wait -WindowStyle Hidden

        Test-Path -LiteralPath "$TempDir\qiiwexc.ps1" | Should -BeTrue
        Get-Content -LiteralPath $MarkerFile -Tail 1 | Should -BeExactly "$LauncherDir|False"
    }

    It 'Should start the script in dev mode' {
        Start-Process cmd.exe -ArgumentList '/c', "$SetTempDir `"$LauncherDir\qiiwexc.bat`" Debug" -WorkingDirectory $TestDrive -Wait -WindowStyle Hidden

        Get-Content -LiteralPath $MarkerFile -Tail 1 | Should -BeExactly "$LauncherDir|True"
    }
}
