Set-Variable -Scope Script -Name APP_INSTANCE -Value $Null

# One copy of the app at a time: each one empties the app's temp folder as it starts, from which another may be
# downloading or running a tool. A copy restarting into a new version is given a few seconds to exit first.
# Returns whether this copy may run; it then holds the mutex until Exit-AppInstance
function Enter-AppInstance {
    param(
        [String]$Name = 'Local\qiiwexc',
        [Int]$TimeoutSeconds = 5
    )

    Set-Variable -Option Constant Mutex ([Threading.Mutex]::new($False, $Name))

    [Bool]$Acquired = $False
    try {
        $Acquired = $Mutex.WaitOne([TimeSpan]::FromSeconds($TimeoutSeconds))
    } catch [Threading.AbandonedMutexException] {
        # The copy that held it ended without letting go of it, as one whose process was ended does
        $Acquired = $True
    }

    if (-not $Acquired) {
        $Mutex.Dispose()
        return $False
    }

    $script:APP_INSTANCE = $Mutex
    return $True
}


# On the thread that called Enter-AppInstance, which a mutex belongs to
function Exit-AppInstance {
    if ($script:APP_INSTANCE) {
        $script:APP_INSTANCE.ReleaseMutex()
        $script:APP_INSTANCE.Dispose()
        $script:APP_INSTANCE = $Null
    }
}
