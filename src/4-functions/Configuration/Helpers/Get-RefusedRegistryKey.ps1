# reg.exe writes every entry it can and reports only that something failed, not what. Importing each key on its own
# again, with the same data, names the keys it could not write, such as those Windows protects from scripted changes
function Get-RefusedRegistryKey {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Content,
        [Parameter(Position = 1, Mandatory)][String]$Path
    )

    # Comments dropped, so that a key listed twice is imported once
    Set-Variable -Option Constant Sections ([String[]]@(
            [Regex]::Split($Content, '(?m)^(?=\[)') |
                Where-Object { $_.StartsWith('[') } |
                ForEach-Object { ((@($_ -split '\r?\n') | Where-Object { $_ -notmatch '^\s*;' }) -join "`n").Trim() } |
                Select-Object -Unique
        ))

    foreach ($Section in $Sections) {
        "Windows Registry Editor Version 5.00`n`n$Section`n" | Set-Content $Path -NoNewline -ErrorAction Stop

        if ((Invoke-RegistryImport $Path) -ne 0) {
            ($Section -split "`n")[0].Trim()
        }
    }
}
