function Invoke-GitAPI {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Uri,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Write-LogInfo "Invoking API: $Uri" 1

    try {
        if ($GitHubToken) {
            Set-Variable -Option Constant Response ([Object](Invoke-WebRequest $Uri -Method Get -UseBasicParsing -Headers @{ Authorization = "token $GitHubToken" }))
        } else {
            Set-Variable -Option Constant Response ([Object](Invoke-WebRequest $Uri -Method Get -UseBasicParsing))
        }
    } catch {
        Write-LogError "Failed to invoke API: $Uri`n$_" 1
        return $Null
    }

    return [Collections.Generic.List[Object]]($Response.Content | ConvertFrom-Json)
}
