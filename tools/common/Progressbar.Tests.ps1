BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\logger.ps1"

    Set-Variable -Option Constant TestActivity ([String]'TEST_ACTIVITY')
}

# The progress bar itself is the app's, and its tests are next to it in src; these cover what the build replaces
Describe 'Progressbar' {
    BeforeAll {
        Mock Write-Host {}
        Mock Write-Progress {}
    }

    It 'Should report an activity through Write-Progress alone' {
        New-Activity $TestActivity
        Write-ActivityProgress 50
        Write-ActivityCompleted

        Should -Invoke Write-Progress -Exactly 3
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter { $Activity -eq $TestActivity -and $PercentComplete -eq 50 }
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter { $Activity -eq $TestActivity -and $Completed }
        $ACTIVITIES.Count | Should -Be 0
    }

    It 'Should change nothing in a window' {
        Set-Icon ([IconName]::Working) | Should -BeNullOrEmpty
        Invoke-OnDispatcher ([Action] { throw 'The build has no window to dispatch to' }) -FlushRender | Should -BeNullOrEmpty
    }
}
