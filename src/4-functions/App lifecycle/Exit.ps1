function Reset-State {
    param(
        [Switch]$Update
    )

    if (-not $Update) {
        Remove-File "$PATH_TEMP_DIR\qiiwexc.ps1" -Silent
    }

    $HOST.UI.RawUI.WindowTitle = $ORIGINAL_WINDOW_TITLE
    Write-Host ''
}

# Closing the window ends the process, and with it a running operation midway, such as a registry import or a DISM run.
# Asks first while one runs that its button could cancel; one without, such as the update check at startup, ends with
# the window. Returns whether the window may close
function Confirm-AppExit {
    if (-not ($script:ASYNC.Running -and $script:ASYNC.Button)) {
        return $True
    }

    Set-Variable -Option Constant Answer ([String](Show-MessageBox 'An operation is still running. Closing the window stops it midway. Close anyway?' -Buttons 'YesNo' -Icon 'Warning' -Default 'No' -Owner $FORM))

    if ($Answer -ne 'Yes') {
        return $False
    }

    Stop-AsyncOperation
    return $True
}

function Exit-App {
    param(
        [Switch]$Update
    )

    Write-LogInfo 'Exiting the app...'
    Reset-State -Update:$Update
    try { $FORM.Close() } catch { $null = $_ }
}
