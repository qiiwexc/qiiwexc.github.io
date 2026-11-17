BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\Invoke-RegCommand.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
}

Describe 'Dismount-DefaultUserHive' {
    BeforeAll {
        Mock Invoke-RegCommand { return 0 }
        Mock Start-Sleep {}
        Mock Write-LogDebug {}
        Mock Write-LogWarning {}
    }

    It 'Should unload the default user profile' {
        Dismount-DefaultUserHive

        Should -Invoke Invoke-RegCommand -Exactly 1
        Should -Invoke Invoke-RegCommand -Exactly 1 -ParameterFilter { ($Arguments -join ' ') -eq 'unload HKU\DefaultUser' }
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should retry an unload that fails until it succeeds' {
        $script:Exits = [Collections.Generic.Queue[Int]]::new([Int[]]@(1, 1, 0))
        Mock Invoke-RegCommand { return $script:Exits.Dequeue() }

        Dismount-DefaultUserHive

        Should -Invoke Invoke-RegCommand -Exactly 3
        Should -Invoke Start-Sleep -Exactly 2
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should warn that new accounts cannot sign in when every attempt fails' {
        Mock Invoke-RegCommand { return 1 }

        Dismount-DefaultUserHive

        Should -Invoke Invoke-RegCommand -Exactly 5
        Should -Invoke Start-Sleep -Exactly 4
        Should -Invoke Write-LogWarning -Exactly 1 -ParameterFilter { $Message -match 'until Windows restarts: reg\.exe exited with code 1' }
    }

    It 'Should not throw when reg.exe cannot be started' {
        Mock Invoke-RegCommand { throw $TestException }

        { Dismount-DefaultUserHive } | Should -Not -Throw

        Should -Invoke Invoke-RegCommand -Exactly 5
        Should -Invoke Write-LogWarning -Exactly 1 -ParameterFilter { $Message -match $TestException }
    }
}
