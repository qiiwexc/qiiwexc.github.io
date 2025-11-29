Add-Type -TypeDefinition @'
    public enum Mode {
        compare,
        tags,
        commits
    }
'@

function Update-GitDependency {
    param(
        [Object][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Mode ([Mode]$Dependency.mode)

    switch ($Mode) {
        ([Mode]::compare) {
            return Compare-Tags $Dependency $GitHubToken
        }
        ([Mode]::tags) {
            return Select-Tags $Dependency $GitHubToken
        }
        ([Mode]::commits) {
            return Compare-Commits $Dependency $GitHubToken
        }
        Default {
            Write-LogWarning "Unknown mode '$($Mode)' for dependency '$($Dependency.name)'. Skipping."
        }
    }
}
