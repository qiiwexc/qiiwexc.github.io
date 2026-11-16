# Writes UTF-8 whatever the code page of the machine running the build: Set-Content's default, the ANSI code page,
# replaces every character outside it, and Read-TextFile reads what the build wrote back as UTF-8. A PowerShell script
# gets a byte order mark, without which Windows PowerShell 5.1 reads it as ANSI; nothing else does, since cmd.exe reads
# the mark of a batch file as part of its first command.
# The content is written as given, unless -Normalize: then trailing white space is trimmed and every line ends in LF,
# or in CRLF with -CrLf, the last one included
function Write-TextFile {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNullOrEmpty()][String]$Path,
        [Parameter(Position = 1, Mandatory)][AllowEmptyString()][String[]]$Content,
        [Switch]$Normalize,
        [Switch]$CrLf
    )

    [String]$Text = -join $Content

    if ($Normalize) {
        Set-Variable -Option Constant LineEnding ([String]$(if ($CrLf) { "`r`n" } else { "`n" }))
        $Text = ($Text.TrimEnd() -replace '\r?\n', $LineEnding) + $LineEnding
    }

    Set-Variable -Option Constant ByteOrderMark ([Bool]([IO.Path]::GetExtension($Path) -eq '.ps1'))

    # .NET resolves a relative path against the process's directory, not PowerShell's current location
    Set-Variable -Option Constant FullPath ([String]$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path))
    [Void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($FullPath))

    [IO.File]::WriteAllText($FullPath, $Text, [Text.UTF8Encoding]::new($ByteOrderMark))
}
