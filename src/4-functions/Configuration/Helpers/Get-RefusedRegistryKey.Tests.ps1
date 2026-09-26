BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\Invoke-RegistryImport.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
    Set-Variable -Option Constant TestPath ([String]'TEST_PATH\TEST_APP_NAME (one key).reg')
    Set-Variable -Option Constant Header ([String]"Windows Registry Editor Version 5.00`n`n")
}

Describe 'Get-RefusedRegistryKey' {
    BeforeAll {
        Mock Set-Content { $script:Written.Add($Value) }
        # Refuses every key whose section has a REFUSED value
        Mock Invoke-RegistryImport { if ($script:Written[-1] -match 'REFUSED') { return 1 } return 0 }
    }

    BeforeEach {
        [Collections.Generic.List[String]]$script:Written = @()
    }

    It 'Should import each key on its own and return the refused ones' {
        [String]$Content = "; Comment`n[HKEY_A]`n`"Value`"=dword:00000001`n`n; Refused`n[HKEY_B]`n`"REFUSED`"=dword:00000000`n`n[-HKEY_C]`n"

        [String[]]$Refused = @(Get-RefusedRegistryKey $Content $TestPath)

        $Refused | Should -BeExactly @('[HKEY_B]')
        $script:Written | Should -BeExactly @(
            "$Header[HKEY_A]`n`"Value`"=dword:00000001`n",
            "$Header[HKEY_B]`n`"REFUSED`"=dword:00000000`n",
            "$Header[-HKEY_C]`n"
        )
        Should -Invoke Set-Content -Exactly 3 -ParameterFilter { $Path -eq $TestPath -and $NoNewline }
        Should -Invoke Invoke-RegistryImport -Exactly 3 -ParameterFilter { $Path -eq $TestPath }
    }

    It 'Should import a key listed twice once' {
        [String]$Content = "[HKEY_B]`r`n`"REFUSED`"=dword:00000000`r`n`r`n[HKEY_A]`r`n`"Value`"=dword:00000001`r`n`r`n; Again`r`n[HKEY_B]`r`n`"REFUSED`"=dword:00000000`r`n`r`n"

        [String[]]$Refused = @(Get-RefusedRegistryKey $Content $TestPath)

        $Refused | Should -BeExactly @('[HKEY_B]')
        Should -Invoke Invoke-RegistryImport -Exactly 2
    }

    It 'Should return nothing when every key is written' {
        @(Get-RefusedRegistryKey "[HKEY_A]`n`"Value`"=dword:00000001`n" $TestPath) | Should -HaveCount 0
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { Get-RefusedRegistryKey "[HKEY_A]`n" $TestPath } | Should -Throw $TestException

        Should -Invoke Invoke-RegistryImport -Exactly 0
    }

    It 'Should handle Invoke-RegistryImport failure' {
        Mock Invoke-RegistryImport { throw $TestException }

        { Get-RefusedRegistryKey "[HKEY_A]`n" $TestPath } | Should -Throw $TestException
    }
}
