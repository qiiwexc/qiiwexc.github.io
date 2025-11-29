function Invoke-GitAPI {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Uri,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Write-LogInfo "Invoking API: $Uri" 1

    try {
        if ($GitHubToken) {
            Set-Variable -Option Constant Response ([Object](Invoke-WebRequest -Uri $Uri -Method Get -Headers @{ Authorization = "token $GitHubToken" }))
        } else {
            Set-Variable -Option Constant Response ([Object](Invoke-WebRequest -Uri $Uri -Method Get))
        }
    } catch {
        Write-LogError "Failed to invoke API: $Uri`n$_" 1
        return $null
    }

    return [Collections.Generic.List[Object]]($Response.Content | ConvertFrom-Json)
}
