function Invoke-RegistryImport {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Path
    )

    # Unlike 'regedit /s', reg.exe reports a failed import through its exit code. '/reg:64' keeps the 64-bit view
    # regedit writes to, even from a 32-bit PowerShell on a 64-bit system
    [String[]]$Arguments = @('import', "`"$Path`"")
    if ($OS_64_BIT) {
        $Arguments += '/reg:64'
    }

    return Invoke-RegCommand $Arguments
}
