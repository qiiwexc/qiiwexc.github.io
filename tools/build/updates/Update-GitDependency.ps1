function Update-GitDependency {
    param(
        [ValidateNotNull()][PSObject][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Mode ([String]$Dependency.mode)

    switch ($Mode) {
        ('compare') {
            return Compare-Tags $Dependency $GitHubToken
        }
        ('tags') {
            return Select-Tags $Dependency $GitHubToken
        }
        ('commits') {
            return Compare-Commits $Dependency $GitHubToken
        }
    }
}
