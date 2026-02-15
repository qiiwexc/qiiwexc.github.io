BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Find-RunningProcesses.ps1'
    . '.\src\4-functions\Common\Find-RunningScript.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestProcess ([PSObject]@{ ProcessName = 'TEST_PROCESS' })
    Set-Variable -Option Constant TestBitsTransfer ([PSObject]@{ JobState = 'Transferring' })
}

Describe 'Test-WindowsDebloatIsRunning' {
    BeforeEach {
        Mock Find-RunningScript {}
    }

    It 'Should return true if debloat is running' {
        Mock Find-RunningScript { return $TestProcess }

        Set-Variable -Option Constant Result ([PSObject](Test-WindowsDebloatIsRunning))

        $Result.ProcessName | Should -BeExactly $TestProcess.ProcessName

        Should -Invoke Find-RunningScript -Exactly 1
        Should -Invoke Find-RunningScript -Exactly 1 -ParameterFilter { $CommandLinePart -eq 'debloat.raphi.re' }
    }

    It 'Should return false if debloat is not running' {
        Test-WindowsDebloatIsRunning | Should -BeNullOrEmpty

        Should -Invoke Find-RunningScript -Exactly 1
    }

    It 'Should handle Find-RunningScript failure' {
        Mock Find-RunningScript { throw $TestException }

        { Test-WindowsDebloatIsRunning } | Should -Throw $TestException

        Should -Invoke Find-RunningScript -Exactly 1
    }
}

Describe 'Test-OOShutUp10IsRunning' {
    BeforeEach {
        Mock Find-RunningProcesses {}
    }

    It 'Should return true if OOShutUp10 is running' {
        Mock Find-RunningProcesses { return $TestProcess }

        Set-Variable -Option Constant Result ([PSObject](Test-OOShutUp10IsRunning))

        $Result.ProcessName | Should -BeExactly $TestProcess.ProcessName

        Should -Invoke Find-RunningProcesses -Exactly 1
        Should -Invoke Find-RunningProcesses -Exactly 1 -ParameterFilter { $ProcessNames -eq 'OOSU10' }
    }

    It 'Should return false if OOShutUp10 is not running' {
        Test-OOShutUp10IsRunning | Should -BeNullOrEmpty

        Should -Invoke Find-RunningProcesses -Exactly 1
    }

    It 'Should handle Find-RunningProcesses failure' {
        Mock Find-RunningProcesses { throw $TestException }

        { Test-OOShutUp10IsRunning } | Should -Throw $TestException

        Should -Invoke Find-RunningProcesses -Exactly 1
    }
}

Describe 'Test-SdiIsRunning' {
    BeforeEach {
        Mock Find-RunningProcesses {}
    }

    It 'Should return true if SDI is running' {
        Mock Find-RunningProcesses { return $TestProcess }

        Set-Variable -Option Constant Result ([PSObject](Test-SdiIsRunning))

        $Result.ProcessName | Should -BeExactly $TestProcess.ProcessName

        Should -Invoke Find-RunningProcesses -Exactly 1
        Should -Invoke Find-RunningProcesses -Exactly 1 -ParameterFilter {
            $ProcessNames.Count -eq 2 -and
            $ProcessNames[0] -eq 'SDI64-drv' -and
            $ProcessNames[1] -eq 'SDI-drv'
        }
    }

    It 'Should return false if SDI is not running' {
        Test-SdiIsRunning | Should -BeNullOrEmpty

        Should -Invoke Find-RunningProcesses -Exactly 1
    }

    It 'Should handle Find-RunningProcesses failure' {
        Mock Find-RunningProcesses { throw $TestException }

        { Test-SdiIsRunning } | Should -Throw $TestException

        Should -Invoke Find-RunningProcesses -Exactly 1
    }
}

Describe 'Test-DownloadingWindowsUpdates' {
    BeforeEach {
        Mock Get-BitsTransfer {}
    }

    It 'Should return true if downloading Windows updates' {
        Mock Get-BitsTransfer { return @($TestBitsTransfer) }

        Set-Variable -Option Constant Result ([PSObject](Test-DownloadingWindowsUpdates))

        $Result.JobState | Should -BeExactly 'Transferring'

        Should -Invoke Get-BitsTransfer -Exactly 1
        Should -Invoke Get-BitsTransfer -Exactly 1 -ParameterFilter { $AllUsers -eq $True }
    }

    It 'Should return false if not downloading Windows updates' {
        Test-DownloadingWindowsUpdates | Should -BeNullOrEmpty

        Should -Invoke Get-BitsTransfer -Exactly 1
    }

    It 'Should return false if no transfers are in transferring state' {
        Mock Get-BitsTransfer { return @(@{ JobState = 'Suspended' }) }

        Test-DownloadingWindowsUpdates | Should -BeNullOrEmpty

        Should -Invoke Get-BitsTransfer -Exactly 1
    }

    It 'Should handle Get-BitsTransfer failure' {
        Mock Get-BitsTransfer { throw $TestException }

        { Test-DownloadingWindowsUpdates } | Should -Throw $TestException

        Should -Invoke Get-BitsTransfer -Exactly 1
    }
}

Describe 'Test-InstallingWindowsUpdates' {
    BeforeEach {
        Mock Find-RunningProcesses {}
    }

    It 'Should return true if installing Windows updates' {
        Mock Find-RunningProcesses { return $TestProcess }

        Set-Variable -Option Constant Result ([PSObject](Test-InstallingWindowsUpdates))

        $Result.ProcessName | Should -BeExactly $TestProcess.ProcessName

        Should -Invoke Find-RunningProcesses -Exactly 1
        Should -Invoke Find-RunningProcesses -Exactly 1 -ParameterFilter {
            $ProcessNames.Count -eq 2 -and
            $ProcessNames[0] -eq 'TiWorker' -and
            $ProcessNames[1] -eq 'TrustedInstaller'
        }
    }

    It 'Should return false if not installing Windows updates' {
        Test-InstallingWindowsUpdates | Should -BeNullOrEmpty

        Should -Invoke Find-RunningProcesses -Exactly 1
    }

    It 'Should handle Find-RunningProcesses failure' {
        Mock Find-RunningProcesses { throw $TestException }

        { Test-InstallingWindowsUpdates } | Should -Throw $TestException

        Should -Invoke Find-RunningProcesses -Exactly 1
    }
}
