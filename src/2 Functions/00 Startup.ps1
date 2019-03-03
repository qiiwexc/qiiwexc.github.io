function Startup {
    $_FORM.Activate()
    $Timestamp = (Get-Date).ToString()
    $_LOG.AppendText("[$Timestamp] Initializing...")
    GatherSystemInformation
    CheckForUpdates
}
