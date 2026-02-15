function Update-GitDependency {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNull()][PSObject]$Dependency,
        [Parameter(Position = 1)][String]$GitHubToken
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
