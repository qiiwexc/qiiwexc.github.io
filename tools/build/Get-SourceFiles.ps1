function Get-SourceFiles {
    param(
        [Parameter(Position = 0, Mandatory)][String]$SourcePath
    )

    Set-Variable -Option Constant Root ([String](Get-Item -LiteralPath $SourcePath -ErrorAction Stop).FullName.TrimEnd('\'))

    [IO.FileInfo[]]$Files = @(Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction Stop | Where-Object { $_.Name -notmatch '.\.Tests\.ps1$' })

    # The order the bundle runs in: a directory's own files before its subdirectories, each level in name
    # order as NTFS lists it (ordinal, ignoring case) - spelled out rather than left to the enumeration.
    # In each file's key, '0' puts it ahead of the directories beside it, which get '1', and the separator
    # sorts below any character of a name, so a name comes before a longer one it begins
    [String[]]$Keys = @(foreach ($File in $Files) {
            [String[]]$Parts = $File.FullName.Substring($Root.Length + 1).Split('\')
            [String[]]$Directories = @(for ($Index = 0; $Index -lt $Parts.Count - 1; $Index++) { "1$($Parts[$Index])" })
            (@($Directories) + "0$($Parts[-1])") -join [Char]1
        })

    [Array]::Sort($Keys, $Files, [StringComparer]::OrdinalIgnoreCase)

    return $Files
}
