function Set-FileAssociations {
    Write-LogInfo 'Setting file associations...'

    Set-Variable -Option Constant ScriptPath "$PATH_TEMP_DIR\Sophia.ps1"

    $Parameters = @{
        Uri             = "https://raw.githubusercontent.com/farag2/Sophia-Script-for-Windows/master/src/Sophia_Script_for_Windows_$OS_VERSION/Module/Sophia.psm1"
        Outfile         = $ScriptPath
        UseBasicParsing = $True
    }
    Invoke-WebRequest @Parameters

    (Get-Content -Path $ScriptPath -Force) | Set-Content -Path $ScriptPath -Encoding UTF8 -Force

    . $ScriptPath

    foreach ($FileAssociation in $CONFIG_FILE_ASSOCIATIONS) {
        Set-Association -ProgramPath $FileAssociation.Application -Extension $FileAssociation.Extension
    }

    Remove-Item -Path $ScriptPath -Force

    Out-Success
}
