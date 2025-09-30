function Reset-State {
    Write-LogInfo 'Cleaning up files on exit...'

    Set-Variable -Option Constant PowerShellScript "$PATH_TEMP_DIR\qiiwexc.ps1"

    if (Test-Path $PATH_WINUTIL) {
        Remove-Item -Force -Recurse $PATH_WINUTIL -ErrorAction Ignore
    }

    if (Test-Path $PATH_APP_DIR) {
        Remove-Item -Force -Recurse $PATH_APP_DIR -ErrorAction Ignore
    }

    if (Test-Path $PowerShellScript) {
        Remove-Item -Force -Recurse $PowerShellScript -ErrorAction Ignore
    }

    $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE
    Write-Host ''
}

function Exit-App {
    Write-LogInfo 'Exiting the app...'
    Reset-State
    $FORM.Close()
}
