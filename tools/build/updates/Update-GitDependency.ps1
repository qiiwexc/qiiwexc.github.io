function Update-GitDependency {
    param(
        [ValidateNotNull()][PSObject][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Mode ([String]$Dependency.mode)

    switch ($Mode) {
        ('tags') {
            return Compare-Tags $Dependency $GitHubToken
        }
        ('releases') {
            return Select-Releases $Dependency $GitHubToken
        }
        ('commits') {
            return Compare-Commits $Dependency $GitHubToken
        }
    }
}
