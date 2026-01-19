function Set-FileAssociations {
    Set-Variable -Option Constant LogIndentLevel 1

    Write-ActivityProgress 30 'Setting file associations...'

    [Collections.Generic.List[PSCustomObject]]$AppAssociations = @()

    Select-Xml -Xml ([xml]$CONFIG_APP_ASSOCIATIONS) -XPath '//Association' | ForEach-Object {
        $AppAssociations.Add(@{
                Application = $_.Node.ProgId
                Extension   = $_.Node.Identifier
            })
    }

    Set-Variable -Option Constant FileTypeCount ([Int]$AppAssociations.Count)
    Set-Variable -Option Constant Step ([Math]::Floor(20 / $FileTypeCount))

    [Int]$Iteration = 1
    foreach ($FileAssociation in $AppAssociations) {
        [Int]$Percentage = 40 + $Iteration * $Step
        Write-ActivityProgress $Percentage
        $Iteration++

        [String]$Extension = $FileAssociation.Extension
        [String]$Application = $FileAssociation.Application

        [String]$OriginalAssociation = $(& cmd.exe /c assoc $Extension 2`>`&1).Replace("$Extension=", '')
        if ($OriginalAssociation -ne $Application) {
            & cmd.exe /c assoc $Extension=$Application
        }
    }

    Out-Success $LogIndentLevel
}
