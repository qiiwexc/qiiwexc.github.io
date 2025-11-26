function Update-GitDependency {
    param(
        [Object][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Mode $Dependency.mode

    switch ($Mode) {
        'compare' {
            return Compare-Tags $Dependency $GitHubToken
        }
        'tags' {
            return Select-Tags $Dependency $GitHubToken
        }
        'commits' {
            return Compare-Commits $Dependency $GitHubToken
        }
        Default {
            Write-LogWarning "Unknown mode '$($Mode)' for dependency '$($Dependency.name)'. Skipping."
        }
    }
}
