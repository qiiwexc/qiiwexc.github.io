function Get-ReleaseNotes {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNullOrEmpty()][String]$Repository,
        [Parameter(Position = 1, Mandatory)][ValidateNotNullOrEmpty()][String]$Tag,
        [Parameter(Position = 2)][String]$GitHubToken
    )

    # A tag without a release answers 404 here, which is not an error for the caller: it gets $Null,
    # and an empty string for a release published without notes
    try {
        Set-Variable -Option Constant Release ([PSObject](Invoke-GitAPI "https://api.github.com/repos/$Repository/releases/tags/$([Uri]::EscapeDataString($Tag))" $GitHubToken | Select-Object -First 1))
    } catch {
        return $Null
    }

    if ($Release -and $Release.PSObject.Properties['body'] -and $Release.body) {
        return [String]$Release.body
    }

    return ''
}
