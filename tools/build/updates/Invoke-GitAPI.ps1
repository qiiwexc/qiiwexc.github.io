function Invoke-GitAPI {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Uri,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    Write-LogInfo "Invoking API: $Uri" $LogIndentLevel

    try {
        if ($GitHubToken) {
            Set-Variable -Option Constant Response ([PSCustomObject](Invoke-WebRequest $Uri -Method Get -UseBasicParsing -Headers @{ Authorization = "token $GitHubToken" }))
        } else {
            Set-Variable -Option Constant Response ([PSCustomObject](Invoke-WebRequest $Uri -Method Get -UseBasicParsing))
        }
    } catch {
        Write-LogError "Failed to invoke API '$Uri': $_"$LogIndentLevel
        return $Null
    }

    return [PSCustomObject[]]($Response.Content | ConvertFrom-Json)
}
