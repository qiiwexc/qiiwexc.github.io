BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Find-RunningProcesses.ps1'
    . '.\src\4-functions\Common\Find-RunningScript.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestProcess ([PSObject]@{ ProcessName = 'TEST_PROCESS' })
    Set-Variable -Option Constant TestBitsTransfer ([PSObject]@{ JobState = 'Transferring' })
}

Describe 'Assert-WindowsDebloatIsRunning' {
    BeforeEach {
        Mock Find-RunningScript {}
    }

    It 'Should return true if debloat is running' {
        Mock Find-RunningScript { return $TestProcess }

        Set-Variable -Option Constant Result ([PSObject](Assert-WindowsDebloatIsRunning))

        $Result.ProcessName | Should -BeExactly $TestProcess.ProcessName

        Should -Invoke Find-RunningScript -Exactly 1
        Should -Invoke Find-RunningScript -Exactly 1 -ParameterFilter { $CommandLinePart -eq 'debloat.raphi.re' }
    }

    It 'Should return false if debloat is not running' {
        Assert-WindowsDebloatIsRunning | Should -BeNullOrEmpty

        Should -Invoke Find-RunningScript -Exactly 1
    }

    It 'Should handle Find-RunningScript failure' {
        Mock Find-RunningScript { throw $TestException }

        { Assert-WindowsDebloatIsRunning } | Should -Throw $TestException

        Should -Invoke Find-RunningScript -Exactly 1
    }
}

Describe 'Assert-WinUtilIsRunning' {
    BeforeEach {
        Mock Find-RunningScript {}
    }

    It 'Should return true if WinUtil is running' {
        Mock Find-RunningScript { return $TestProcess }

        Set-Variable -Option Constant Result ([PSObject](Assert-WinUtilIsRunning))

        $Result.ProcessName | Should -BeExactly $TestProcess.ProcessName

        Should -Invoke Find-RunningScript -Exactly 1
        Should -Invoke Find-RunningScript -Exactly 1 -ParameterFilter { $CommandLinePart -eq 'christitus.com' }
    }

    It 'Should return false if WinUtil is not running' {
        Assert-WinUtilIsRunning | Should -BeNullOrEmpty

        Should -Invoke Find-RunningScript -Exactly 1
    }

    It 'Should handle Find-RunningScript failure' {
        Mock Find-RunningScript { throw $TestException }

        { Assert-WinUtilIsRunning } | Should -Throw $TestException

        Should -Invoke Find-RunningScript -Exactly 1
    }
}

Describe 'Assert-OOShutUp10IsRunning' {
    BeforeEach {
        Mock Find-RunningProcesses {}
    }

    It 'Should return true if OOShutUp10 is running' {
        Mock Find-RunningProcesses { return $TestProcess }

        Set-Variable -Option Constant Result ([PSObject](Assert-OOShutUp10IsRunning))

        $Result.ProcessName | Should -BeExactly $TestProcess.ProcessName

        Should -Invoke Find-RunningProcesses -Exactly 1
        Should -Invoke Find-RunningProcesses -Exactly 1 -ParameterFilter { $ProcessNames -eq 'OOSU10' }
    }

    It 'Should return false if OOShutUp10 is not running' {
        Assert-OOShutUp10IsRunning | Should -BeNullOrEmpty

        Should -Invoke Find-RunningProcesses -Exactly 1
    }

    It 'Should handle Find-RunningProcesses failure' {
        Mock Find-RunningProcesses { throw $TestException }

        { Assert-OOShutUp10IsRunning } | Should -Throw $TestException

        Should -Invoke Find-RunningProcesses -Exactly 1
    }
}

Describe 'Assert-SdiIsRunning' {
    BeforeEach {
        Mock Find-RunningProcesses {}
    }

    It 'Should return true if SDI is running' {
        Mock Find-RunningProcesses { return $TestProcess }

        Set-Variable -Option Constant Result ([PSObject](Assert-SdiIsRunning))

        $Result.ProcessName | Should -BeExactly $TestProcess.ProcessName

        Should -Invoke Find-RunningProcesses -Exactly 1
        Should -Invoke Find-RunningProcesses -Exactly 1 -ParameterFilter {
            $ProcessNames.Count -eq 2 -and
            $ProcessNames[0] -eq 'SDI64-drv' -and
            $ProcessNames[1] -eq 'SDI-drv'
        }
    }

    It 'Should return false if SDI is not running' {
        Assert-SdiIsRunning | Should -BeNullOrEmpty

        Should -Invoke Find-RunningProcesses -Exactly 1
    }

    It 'Should handle Find-RunningProcesses failure' {
        Mock Find-RunningProcesses { throw $TestException }

        { Assert-SdiIsRunning } | Should -Throw $TestException

        Should -Invoke Find-RunningProcesses -Exactly 1
    }
}

Describe 'Assert-DownloadingWindowsUpdates' {
    BeforeEach {
        Mock Get-BitsTransfer {}
    }

    It 'Should return true if downloading Windows updates' {
        Mock Get-BitsTransfer { return @($TestBitsTransfer) }

        Set-Variable -Option Constant Result ([PSObject](Assert-DownloadingWindowsUpdates))

        $Result.JobState | Should -BeExactly 'Transferring'

        Should -Invoke Get-BitsTransfer -Exactly 1
        Should -Invoke Get-BitsTransfer -Exactly 1 -ParameterFilter { $AllUsers -eq $True }
    }

    It 'Should return false if not downloading Windows updates' {
        Assert-DownloadingWindowsUpdates | Should -BeNullOrEmpty

        Should -Invoke Get-BitsTransfer -Exactly 1
    }

    It 'Should return false if no transfers are in transferring state' {
        Mock Get-BitsTransfer { return @(@{ JobState = 'Suspended' }) }

        Assert-DownloadingWindowsUpdates | Should -BeNullOrEmpty

        Should -Invoke Get-BitsTransfer -Exactly 1
    }

    It 'Should handle Get-BitsTransfer failure' {
        Mock Get-BitsTransfer { throw $TestException }

        { Assert-DownloadingWindowsUpdates } | Should -Throw $TestException

        Should -Invoke Get-BitsTransfer -Exactly 1
    }
}

Describe 'Assert-InstallingWindowsUpdates' {
    BeforeEach {
        Mock Find-RunningProcesses {}
    }

    It 'Should return true if installing Windows updates' {
        Mock Find-RunningProcesses { return $TestProcess }

        Set-Variable -Option Constant Result ([PSObject](Assert-InstallingWindowsUpdates))

        $Result.ProcessName | Should -BeExactly $TestProcess.ProcessName

        Should -Invoke Find-RunningProcesses -Exactly 1
        Should -Invoke Find-RunningProcesses -Exactly 1 -ParameterFilter {
            $ProcessNames.Count -eq 2 -and
            $ProcessNames[0] -eq 'TiWorker' -and
            $ProcessNames[1] -eq 'TrustedInstaller'
        }
    }

    It 'Should return false if not installing Windows updates' {
        Assert-InstallingWindowsUpdates | Should -BeNullOrEmpty

        Should -Invoke Find-RunningProcesses -Exactly 1
    }

    It 'Should handle Find-RunningProcesses failure' {
        Mock Find-RunningProcesses { throw $TestException }

        { Assert-InstallingWindowsUpdates } | Should -Throw $TestException

        Should -Invoke Find-RunningProcesses -Exactly 1
    }
}
