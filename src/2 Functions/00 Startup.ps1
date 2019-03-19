function Startup {
    $_FORM.Activate()
    $_LOG.AppendText("[$((Get-Date).ToString())] Initializing...")

    GatherSystemInformation
    CheckForUpdates

    $script:CurrentDirectory = (Split-Path ($MyInvocation.ScriptName))

    if ($_IS_ELEVATED) {
        $_FORM.Text = "$($_FORM.Text): Administrator"
        $ButtonElevate.Text = 'Already elevated'
        $ButtonElevate.Enabled = $False
    }

    $script:GoogleUpdatePath = "C:\Program Files$(if ($_SYSTEM_INFO.Architecture -eq '64-bit') {' (x86)'})\Google\Update\GoogleUpdate.exe"
    $ButtonGoogleUpdate.Enabled = Test-Path $GoogleUpdatePath
}


function ExitScript {$_FORM.Close()}
