function Invoke-GitAPI {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNullOrEmpty()][String]$Uri,
        [Parameter(Position = 1)][String]$GitHubToken
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    Write-LogInfo "Invoking API: $Uri" $LogIndentLevel

    # A server that stops answering fails the check rather than holding up the whole update
    try {
        if ($GitHubToken) {
            Set-Variable -Option Constant Response ([PSObject](Invoke-WebRequest $Uri -Method Get -UseBasicParsing -TimeoutSec 30 -Headers @{ Authorization = "Bearer $GitHubToken" }))
        } else {
            Set-Variable -Option Constant Response ([PSObject](Invoke-WebRequest $Uri -Method Get -UseBasicParsing -TimeoutSec 30))
        }
    } catch {
        Out-Failure "Failed to invoke API '$Uri': $_" $LogIndentLevel
        throw
    }

    return [PSObject[]]($Response.Content | ConvertFrom-Json)
}
