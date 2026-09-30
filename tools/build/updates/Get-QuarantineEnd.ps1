function Get-QuarantineEnd {
    param(
        [Parameter(Position = 0, Mandatory)][DateTime]$FirstSeen
    )

    # A new version waits this long after the update check first sees it, which gives a compromised or
    # broken release time to be noticed upstream before it reaches the app
    Set-Variable -Option Constant QuarantineDays ([Int]7)

    return $FirstSeen.AddDays($QuarantineDays)
}
