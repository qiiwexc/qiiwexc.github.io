BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestActivity1 ([String]'TEST_ACTIVITY_1')
    Set-Variable -Option Constant TestActivity2 ([String]'TEST_ACTIVITY_2')
    Set-Variable -Option Constant TestTask ([String]'TEST_TASK')
    Set-Variable -Option Constant TestPercentComplete ([Int]50)
}

Describe 'New-Activity' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Write-Progress {}
    }

    It 'Should start new activity correctly when no parent activity exists' {
        Set-Variable -Option Constant ACTIVITIES ([Collections.Stack]@())

        New-Activity $TestActivity1

        $ACTIVITIES.Peek() | Should -BeExactly $TestActivity1

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1 -ParameterFilter { $Message -eq "$TestActivity1..." }
        Should -Invoke Write-Progress -Exactly 1
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity1 -and
            $Id -eq 1 -and
            $PercentComplete -eq 1 -and
            $ParentId -eq $Null
        }
    }

    It 'Should start new activity correctly when parent activity exists' {
        Set-Variable -Option Constant ACTIVITIES ([Collections.Stack]@($TestActivity1))

        New-Activity $TestActivity2

        $ACTIVITIES.Peek() | Should -BeExactly $TestActivity2

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Write-Progress -Exactly 1
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity2 -and
            $Id -eq 2 -and
            $PercentComplete -eq 1 -and
            $ParentId -eq 1
        }
    }
}

Describe 'Write-ActivityProgress' {
    BeforeAll {
        Set-Variable -Option Constant ACTIVITIES ([Collections.Stack]@())
    }

    BeforeEach {
        Mock Write-LogInfo {}
        Mock Write-Progress {}

        [String]$script:CURRENT_TASK = $Null
    }

    It 'Should not update an activity if no activity exists' {
        Write-ActivityProgress $TestPercentComplete $TestTask

        Should -Invoke Write-LogInfo -Exactly 0
        Should -Invoke Write-Progress -Exactly 0

        $script:CURRENT_TASK | Should -BeNullOrEmpty
    }

    It 'Should update existing activity when no parent activity exists' {
        $ACTIVITIES.Push($TestActivity1)

        Write-ActivityProgress $TestPercentComplete

        $script:CURRENT_TASK | Should -BeNullOrEmpty

        Should -Invoke Write-LogInfo -Exactly 0
        Should -Invoke Write-Progress -Exactly 1
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity1 -and
            $Id -eq 1 -and
            $PercentComplete -eq $TestPercentComplete -and
            $ParentId -eq $Null -and
            $Status -eq $Null
        }
    }

    It 'Should update existing activity with a task when no parent activity exists' {
        Write-ActivityProgress $TestPercentComplete $TestTask

        $script:CURRENT_TASK | Should -BeExactly $TestTask

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1 -ParameterFilter { $Message -eq $TestTask }
        Should -Invoke Write-Progress -Exactly 1
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity1 -and
            $Id -eq 1 -and
            $PercentComplete -eq $TestPercentComplete -and
            $ParentId -eq $Null -and
            $Status -eq $TestTask
        }
    }

    It 'Should update existing activity when a parent activity exists' {
        $ACTIVITIES.Push($TestActivity2)

        Write-ActivityProgress $TestPercentComplete

        $script:CURRENT_TASK | Should -BeNullOrEmpty

        Should -Invoke Write-LogInfo -Exactly 0
        Should -Invoke Write-Progress -Exactly 1
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity2 -and
            $Id -eq 2 -and
            $PercentComplete -eq $TestPercentComplete -and
            $ParentId -eq 1 -and
            $Status -eq $Null
        }
    }

    It 'Should update existing activity with a task when a parent activity exists' {
        Write-ActivityProgress $TestPercentComplete $TestTask

        $script:CURRENT_TASK | Should -BeExactly $TestTask

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Write-Progress -Exactly 1
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity2 -and
            $Id -eq 2 -and
            $PercentComplete -eq $TestPercentComplete -and
            $ParentId -eq 1 -and
            $Status -eq $TestTask
        }
    }
}

Describe 'Write-ActivityCompleted' {
    BeforeAll {
        Set-Variable -Option Constant ACTIVITIES ([Collections.Stack]@())
    }

    BeforeEach {
        Mock Out-Success {}
        Mock Out-Failure {}
        Mock Write-Progress {}

        [String]$script:CURRENT_TASK = $TestTask
    }

    It 'Should not end an activity if no activity exists' {
        Write-ActivityCompleted $True

        $script:CURRENT_TASK | Should -BeNullOrEmpty
        $ACTIVITIES.Count | Should -BeExactly 0

        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-Progress -Exactly 0
    }

    It 'Should end existing activity when no parent activity exists' {
        $ACTIVITIES.Push($TestActivity1)

        Write-ActivityCompleted $False

        $script:CURRENT_TASK | Should -BeNullOrEmpty
        $ACTIVITIES.Count | Should -BeExactly 0

        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Write-Progress -Exactly 1
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity1 -and
            $Id -eq 1 -and
            $Completed -eq $True -and
            $ParentId -eq $Null
        }
    }

    It 'Should end existing activity when a parent activity exists' {
        $ACTIVITIES.Push($TestActivity1)
        $ACTIVITIES.Push($TestActivity2)

        Write-ActivityCompleted

        $script:CURRENT_TASK | Should -BeNullOrEmpty
        $ACTIVITIES.Count | Should -BeExactly 1

        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-Progress -Exactly 1
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity2 -and
            $Id -eq 2 -and
            $Completed -eq $True -and
            $ParentId -eq 1
        }
    }
}
