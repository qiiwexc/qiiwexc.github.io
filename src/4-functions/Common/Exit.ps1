function Reset-State {
    param(
        [Switch][Parameter(Position = 0)]$Update
    )

    if (-not $Update) {
        Remove-File "$PATH_TEMP_DIR\qiiwexc.ps1" -Silent
    }

    $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE
    Write-Host ''
}

function Exit-App {
    param(
        [Switch][Parameter(Position = 0)]$Update
    )

    Write-LogInfo 'Exiting the app...'
    Reset-State -Update:$Update
    $FORM.Close()
}
