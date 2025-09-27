function Reset-State {
    Write-Log $INF "Cleaning up '$PATH_APP_DIR'"
    Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $PATH_APP_DIR
    $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE
    Write-Output ''
}

function Exit-Script {
    Reset-State
    $FORM.Close()
}
