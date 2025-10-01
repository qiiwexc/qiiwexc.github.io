function Reset-State {
    Write-LogInfo 'Cleaning up files on exit...'

    Set-Variable -Option Constant PowerShellScript "$PATH_TEMP_DIR\qiiwexc.ps1"

    Remove-Directory $PATH_WINUTIL -Silent
    Remove-Directory $PATH_OOSHUTUP10 -Silent
    Remove-Directory $PATH_APP_DIR -Silent

    Remove-File $PowerShellScript -Silent

    $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE
    Write-Host ''
}

function Exit-App {
    Write-LogInfo 'Exiting the app...'
    Reset-State
    $FORM.Close()
}
