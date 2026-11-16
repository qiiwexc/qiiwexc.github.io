BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    # Holds a mutex on a thread of its own, as another copy of the app would, until told to let go of it or to end
    # without doing so
    function Start-MutexHolder([String]$Name) {
        Set-Variable -Option Constant Holder ([Hashtable]@{
                PowerShell = [PowerShell]::Create()
                Ready      = [Threading.ManualResetEvent]::new($False)
                Done       = [Threading.ManualResetEvent]::new($False)
                Release    = [Ref]$True
            })
        [Void]$Holder.PowerShell.AddScript({
                param($Name, $Ready, $Done, $Release)
                $Mutex = [Threading.Mutex]::new($True, $Name)
                [Void]$Ready.Set()
                [Void]$Done.WaitOne()
                if ($Release.Value) {
                    $Mutex.ReleaseMutex()
                }
                $Mutex.Dispose()
            }).AddArgument($Name).AddArgument($Holder.Ready).AddArgument($Holder.Done).AddArgument($Holder.Release)
        $Holder.Handle = $Holder.PowerShell.BeginInvoke()
        [Void]$Holder.Ready.WaitOne(10000)
        return $Holder
    }

    function Stop-MutexHolder([Hashtable]$Holder, [Switch]$WithoutRelease) {
        $Holder.Release.Value = -not $WithoutRelease
        [Void]$Holder.Done.Set()
        [Void]$Holder.PowerShell.EndInvoke($Holder.Handle)
        $Holder.PowerShell.Dispose()
    }
}

Describe 'Enter-AppInstance' {
    BeforeEach {
        Set-Variable -Option Constant TestName ([String]"Local\qiiwexc-test-$([Guid]::NewGuid())")
        $script:APP_INSTANCE = $Null
    }

    AfterEach {
        Exit-AppInstance
    }

    It 'Should let the first copy run and hold the mutex' {
        Enter-AppInstance -Name $TestName -TimeoutSeconds 0 | Should -BeTrue

        $script:APP_INSTANCE | Should -BeOfType [Threading.Mutex]
    }

    It 'Should not let a second copy run while the first holds the mutex' {
        Set-Variable -Option Constant Holder ([Hashtable](Start-MutexHolder $TestName))
        try {
            Enter-AppInstance -Name $TestName -TimeoutSeconds 0 | Should -BeFalse

            $script:APP_INSTANCE | Should -BeNullOrEmpty
        } finally {
            Stop-MutexHolder $Holder
        }
    }

    It 'Should let a copy run once the one before it has let go of the mutex' {
        Set-Variable -Option Constant Holder ([Hashtable](Start-MutexHolder $TestName))
        Stop-MutexHolder $Holder

        Enter-AppInstance -Name $TestName -TimeoutSeconds 5 | Should -BeTrue
    }

    It 'Should let a copy run when the one before it ended without letting go of the mutex' {
        Set-Variable -Option Constant Holder ([Hashtable](Start-MutexHolder $TestName))
        Stop-MutexHolder $Holder -WithoutRelease

        Enter-AppInstance -Name $TestName -TimeoutSeconds 5 | Should -BeTrue
    }
}

Describe 'Exit-AppInstance' {
    It 'Should let go of the mutex, so that another copy can run' {
        Set-Variable -Option Constant TestName ([String]"Local\qiiwexc-test-$([Guid]::NewGuid())")
        Enter-AppInstance -Name $TestName -TimeoutSeconds 0 | Should -BeTrue

        Exit-AppInstance

        $script:APP_INSTANCE | Should -BeNullOrEmpty
        Set-Variable -Option Constant Holder ([Hashtable](Start-MutexHolder $TestName))
        Stop-MutexHolder $Holder
    }

    It 'Should do nothing when this copy holds no mutex' {
        $script:APP_INSTANCE = $Null

        { Exit-AppInstance } | Should -Not -Throw
    }
}
