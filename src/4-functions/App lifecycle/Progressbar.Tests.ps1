BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\types.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\App lifecycle\Set-Icon.ps1'

    Set-Variable -Option Constant TestActivity1 ([String]'TEST_ACTIVITY_1')
    Set-Variable -Option Constant TestActivity2 ([String]'TEST_ACTIVITY_2')
    Set-Variable -Option Constant TestTask ([String]'TEST_TASK')
    Set-Variable -Option Constant TestPercentComplete ([Int]50)
}

Describe 'Invoke-WriteProgress' {
    BeforeEach {
        $PROGRESSBAR = [PSCustomObject]@{ Value = 0 }
        Mock Write-Progress {}
    }

    It 'Should call Write-Progress with basic parameters' {
        Invoke-WriteProgress -Id 1 -Activity $TestActivity1 -PercentComplete $TestPercentComplete

        $PROGRESSBAR.Value | Should -Be $TestPercentComplete

        Should -Invoke Write-Progress -Exactly 1
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter {
            $Id -eq 1 -and
            $Activity -eq $TestActivity1 -and
            $PercentComplete -eq $TestPercentComplete -and
            $ParentId -eq $Null -and
            $Status -eq $Null -and
            $Completed -eq $Null
        }
    }

    It 'Should include ParentId when greater than 0' {
        Invoke-WriteProgress -Id 2 -Activity $TestActivity1 -ParentId 1 -PercentComplete $TestPercentComplete

        $PROGRESSBAR.Value | Should -Be $TestPercentComplete

        Should -Invoke Write-Progress -Exactly 1
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter {
            $Id -eq 2 -and
            $Activity -eq $TestActivity1 -and
            $PercentComplete -eq $TestPercentComplete -and
            $ParentId -eq 1
        }
    }

    It 'Should not include ParentId when 0' {
        Invoke-WriteProgress -Id 1 -Activity $TestActivity1 -ParentId 0 -PercentComplete $TestPercentComplete

        $PROGRESSBAR.Value | Should -Be $TestPercentComplete

        Should -Invoke Write-Progress -Exactly 1
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter {
            $Id -eq 1 -and
            $ParentId -eq $Null
        }
    }

    It 'Should include Status when provided' {
        Invoke-WriteProgress -Id 1 -Activity $TestActivity1 -PercentComplete $TestPercentComplete -Status $TestTask

        $PROGRESSBAR.Value | Should -Be $TestPercentComplete

        Should -Invoke Write-Progress -Exactly 1
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity1 -and
            $Status -eq $TestTask
        }
    }

    It 'Should use Completed flag instead of PercentComplete' {
        Invoke-WriteProgress -Id 1 -Activity $TestActivity1 -Completed

        $PROGRESSBAR.Value | Should -Be 100

        Should -Invoke Write-Progress -Exactly 1
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter {
            $Id -eq 1 -and
            $Activity -eq $TestActivity1 -and
            $Completed -eq $True -and
            $PercentComplete -eq $Null
        }
    }

    It 'Should pass all parameters together correctly' {
        Invoke-WriteProgress -Id 3 -Activity $TestActivity2 -ParentId 2 -PercentComplete 75 -Status $TestTask

        $PROGRESSBAR.Value | Should -Be 75

        Should -Invoke Write-Progress -Exactly 1
        Should -Invoke Write-Progress -Exactly 1 -ParameterFilter {
            $Id -eq 3 -and
            $Activity -eq $TestActivity2 -and
            $ParentId -eq 2 -and
            $PercentComplete -eq 75 -and
            $Status -eq $TestTask
        }
    }
}

Describe 'New-Activity' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Set-Icon {}
        Mock Invoke-WriteProgress {}
    }

    It 'Should start new activity correctly when no parent activity exists' {
        Set-Variable -Option Constant ACTIVITIES ([Collections.Stack]@())

        New-Activity $TestActivity1

        $ACTIVITIES.Peek() | Should -BeExactly $TestActivity1

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1 -ParameterFilter { $Message -eq "$TestActivity1..." }
        Should -Invoke Set-Icon -Exactly 1
        Should -Invoke Set-Icon -Exactly 1 -ParameterFilter { $Name -eq ([IconName]::Working) }
        Should -Invoke Invoke-WriteProgress -Exactly 1
        Should -Invoke Invoke-WriteProgress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity1 -and
            $Id -eq 1 -and
            $PercentComplete -eq 5 -and
            $ParentId -eq 0
        }
    }

    It 'Should start new activity correctly when parent activity exists' {
        Set-Variable -Option Constant ACTIVITIES ([Collections.Stack]@($TestActivity1))

        New-Activity $TestActivity2

        $ACTIVITIES.Peek() | Should -BeExactly $TestActivity2

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Set-Icon -Exactly 1
        Should -Invoke Set-Icon -Exactly 1 -ParameterFilter { $Name -eq ([IconName]::Working) }
        Should -Invoke Invoke-WriteProgress -Exactly 1
        Should -Invoke Invoke-WriteProgress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity2 -and
            $Id -eq 2 -and
            $PercentComplete -eq 5 -and
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
        Mock Invoke-WriteProgress {}

        [String]$script:CURRENT_TASK = $Null
    }

    It 'Should not update an activity if no activity exists' {
        Write-ActivityProgress $TestPercentComplete $TestTask

        Should -Invoke Write-LogInfo -Exactly 0
        Should -Invoke Invoke-WriteProgress -Exactly 0

        $script:CURRENT_TASK | Should -BeNullOrEmpty
    }

    It 'Should update existing activity when no parent activity exists' {
        $ACTIVITIES.Push($TestActivity1)

        Write-ActivityProgress $TestPercentComplete

        $script:CURRENT_TASK | Should -BeNullOrEmpty

        Should -Invoke Write-LogInfo -Exactly 0
        Should -Invoke Invoke-WriteProgress -Exactly 1
        Should -Invoke Invoke-WriteProgress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity1 -and
            $Id -eq 1 -and
            $PercentComplete -eq $TestPercentComplete -and
            $ParentId -eq 0 -and
            (-not $Status)
        }
    }

    It 'Should update existing activity with a task when no parent activity exists' {
        Write-ActivityProgress $TestPercentComplete $TestTask

        $script:CURRENT_TASK | Should -BeExactly $TestTask

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1 -ParameterFilter { $Message -eq $TestTask }
        Should -Invoke Invoke-WriteProgress -Exactly 1
        Should -Invoke Invoke-WriteProgress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity1 -and
            $Id -eq 1 -and
            $PercentComplete -eq $TestPercentComplete -and
            $ParentId -eq 0 -and
            $Status -eq $TestTask
        }
    }

    It 'Should update existing activity when a parent activity exists' {
        $ACTIVITIES.Push($TestActivity2)

        Write-ActivityProgress $TestPercentComplete

        $script:CURRENT_TASK | Should -BeNullOrEmpty

        Should -Invoke Write-LogInfo -Exactly 0
        Should -Invoke Invoke-WriteProgress -Exactly 1
        Should -Invoke Invoke-WriteProgress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity2 -and
            $Id -eq 2 -and
            $PercentComplete -eq $TestPercentComplete -and
            $ParentId -eq 1 -and
            (-not $Status)
        }
    }

    It 'Should update existing activity with a task when a parent activity exists' {
        Write-ActivityProgress $TestPercentComplete $TestTask

        $script:CURRENT_TASK | Should -BeExactly $TestTask

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Invoke-WriteProgress -Exactly 1
        Should -Invoke Invoke-WriteProgress -Exactly 1 -ParameterFilter {
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
        $PROGRESSBAR = [PSCustomObject]@{ Value = 50 }
        Mock Out-Success {}
        Mock Out-Failure {}
        Mock Invoke-WriteProgress {}
        Mock Set-Icon {}

        [String]$script:CURRENT_TASK = $TestTask
    }

    It 'Should not end an activity if no activity exists' {
        Write-ActivityCompleted $True

        $script:CURRENT_TASK | Should -BeNullOrEmpty
        $ACTIVITIES.Count | Should -BeExactly 0
        $PROGRESSBAR.Value | Should -Be 0

        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Invoke-WriteProgress -Exactly 0
        Should -Invoke Set-Icon -Exactly 1
        Should -Invoke Set-Icon -Exactly 1 -ParameterFilter { $Name -eq ([IconName]::Default) }
    }

    It 'Should end existing activity when no parent activity exists' {
        $ACTIVITIES.Push($TestActivity1)

        Write-ActivityCompleted $False

        $script:CURRENT_TASK | Should -BeNullOrEmpty
        $ACTIVITIES.Count | Should -BeExactly 0
        $PROGRESSBAR.Value | Should -Be 0

        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -eq "$TestTask failed" }
        Should -Invoke Invoke-WriteProgress -Exactly 1
        Should -Invoke Invoke-WriteProgress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity1 -and
            $Id -eq 1 -and
            $Completed -eq $True -and
            $ParentId -eq 0
        }
        Should -Invoke Set-Icon -Exactly 1
        Should -Invoke Set-Icon -Exactly 1 -ParameterFilter { $Name -eq ([IconName]::Default) }
    }

    It 'Should end existing activity when a parent activity exists' {
        $ACTIVITIES.Push($TestActivity1)
        $ACTIVITIES.Push($TestActivity2)

        Write-ActivityCompleted

        $script:CURRENT_TASK | Should -BeNullOrEmpty
        $ACTIVITIES.Count | Should -BeExactly 1
        $PROGRESSBAR.Value | Should -Be 0

        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Invoke-WriteProgress -Exactly 1
        Should -Invoke Invoke-WriteProgress -Exactly 1 -ParameterFilter {
            $Activity -eq $TestActivity2 -and
            $Id -eq 2 -and
            $Completed -eq $True -and
            $ParentId -eq 1
        }
        Should -Invoke Set-Icon -Exactly 1
        Should -Invoke Set-Icon -Exactly 1 -ParameterFilter { $Name -eq ([IconName]::Default) }
    }
}
