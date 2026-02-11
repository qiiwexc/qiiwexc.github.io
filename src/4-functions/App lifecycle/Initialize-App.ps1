function Initialize-App {
    $FORM.Activate()

    Write-FormLog ([LogLevel]::INFO) ([String]"[$((Get-Date).ToString())] Initializing...") -NoNewLine

    Get-SystemInformation

    Remove-Directory $PATH_OOSHUTUP10 -Silent
    Remove-Directory $PATH_APP_DIR -Silent

    Initialize-AppDirectory

    Update-App
}
