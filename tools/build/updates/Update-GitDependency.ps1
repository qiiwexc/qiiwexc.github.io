function Update-GitDependency {
    param(
        [PSCustomObject][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Mode ([GitDependencyMode]$Dependency.mode)

    switch ($Mode) {
        ([GitDependencyMode]::compare) {
            return Compare-Tags $Dependency $GitHubToken
        }
        ([GitDependencyMode]::tags) {
            return Select-Tags $Dependency $GitHubToken
        }
        ([GitDependencyMode]::commits) {
            return Compare-Commits $Dependency $GitHubToken
        }
    }
}
