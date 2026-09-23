function Initialize-App {
    $FORM.Activate()

    Write-FormLog ([LogLevel]::INFO) ([String]"[$((Get-Date).ToString())] Initializing...") -NoNewLine

    Remove-Directory $PATH_OOSHUTUP10 -Silent
    Remove-Directory $PATH_APP_DIR -Silent

    Initialize-AppDirectory

    # System queries and the update check can take seconds on a slow network — keep them off the UI thread.
    # Closing the window has to happen on the UI thread, hence the completion handler
    Start-AsyncOperation { Get-SystemInformation; Update-App } -Variables @{ DevMode = $DevMode } -OnComplete {
        param($Output)
        if ($Output -contains $True) {
            Exit-App -Update
        }
    }
}
