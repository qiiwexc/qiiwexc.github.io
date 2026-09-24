function Format-DependencyVersion {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Version
    )

    # Commit-tracked dependencies record full SHAs, which only need their short form to be read
    if ($Version -match '^[0-9a-f]{40}$') {
        return $Version.Substring(0, 7)
    }

    return $Version
}


function Get-DependencyHome {
    param(
        [Parameter(Position = 0, Mandatory)][PSObject]$Dependency
    )

    if ($Dependency.PSObject.Properties['repository'] -and $Dependency.repository) {
        Set-Variable -Option Constant GitHost ([String]$(if ($Dependency.source -eq 'GitLab') { 'gitlab.com' } else { 'github.com' }))
        return "https://$GitHost/$($Dependency.repository)"
    }

    if ($Dependency.PSObject.Properties['url'] -and $Dependency.url) {
        return [String]$Dependency.url
    }

    return ''
}


function ConvertTo-ChangelogLink {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Url,
        [Parameter(Position = 1, Mandatory)][AllowEmptyCollection()][PSObject[]]$Updates
    )

    [String]$Owner = ''
    foreach ($Update in $Updates) {
        [String]$DependencyHome = Get-DependencyHome $Update.Dependency
        if ($DependencyHome -and ($Url -eq $DependencyHome -or $Url.StartsWith("$DependencyHome/", [StringComparison]::OrdinalIgnoreCase))) {
            $Owner = $Update.Name
            break
        }
    }

    if ($Url -match '^https://github\.com/(?<repository>[^/]+/[^/]+)/releases/tag/(?<tag>[^/?#]+)$') {
        Set-Variable -Option Constant Tag ([String][Uri]::UnescapeDataString($Matches['tag']))
        return [PSCustomObject]@{ Url = $Url; Kind = 'Release'; Label = $Tag; Owner = $Owner; Repository = $Matches['repository']; Tag = $Tag }
    }

    Set-Variable -Option Constant Kind ([String]$(if ($Url.StartsWith('https://github.com/')) { 'Commits' } else { 'Other' }))

    [String]$Label = ''
    if ($Url -match '/compare/(?<from>[^/?#]+?)\.\.\.(?<to>[^/?#]+)$') {
        $Label = "``$(Format-DependencyVersion $Matches['from'])...$(Format-DependencyVersion $Matches['to'])``"
    }

    return [PSCustomObject]@{ Url = $Url; Kind = $Kind; Label = $Label; Owner = $Owner; Repository = ''; Tag = '' }
}


function Get-VersionSortKey {
    param(
        [Parameter(Position = 0, Mandatory)][AllowEmptyString()][String]$Tag
    )

    # Tags that are not versions sort last rather than failing the sort
    try {
        return [Version]($Tag -replace '^v' -replace '-.*$')
    } catch {
        return [Version]'0.0'
    }
}


function New-DependencyUpdateDescription {
    param(
        [Parameter(Position = 0, Mandatory)][PSObject[]]$Updates,
        [Parameter(Position = 1)][AllowEmptyCollection()][String[]]$ChangelogUrls = @(),
        [Parameter(Position = 2)][String]$GitHubToken
    )

    # GitHub rejects a pull request body over 65,536 characters; the rest is headroom for the list
    # of the versions whose notes did not fit
    Set-Variable -Option Constant Budget ([Int]60000)
    Set-Variable -Option Constant Arrow ([String][Char]0x2192)

    [Text.StringBuilder]$Text = [Text.StringBuilder]::new()

    Set-Variable -Option Constant Noun ([String]$(if ($Updates.Count -eq 1) { 'dependency' } else { 'dependencies' }))
    [Void]$Text.Append("Bumps $($Updates.Count) $Noun.`n`n")
    [Void]$Text.Append("| Dependency | From | To | Changes |`n| --- | --- | --- | --- |`n")

    foreach ($Update in $Updates) {
        [String]$DependencyHome = Get-DependencyHome $Update.Dependency
        [String]$Name = if ($DependencyHome) { "[$($Update.Name)]($DependencyHome)" } else { $Update.Name }
        [String]$Change = if ($Update.UrlChange) { 'Download URL' } elseif ($Update.ToolChange) { 'CI tool' } else { 'Version record only' }
        [String]$From = (Format-DependencyVersion $Update.From).Replace('|', '\|')
        [String]$To = (Format-DependencyVersion $Update.To).Replace('|', '\|')

        [Void]$Text.Append("| $Name | ``$From`` | ``$To`` | $Change |`n")
    }

    # Newest version first within each dependency, like a releases page
    Set-Variable -Option Constant Links ([PSObject[]]@(
            $ChangelogUrls |
                Where-Object { $_ } |
                Select-Object -Unique |
                ForEach-Object { ConvertTo-ChangelogLink $_ $Updates } |
                Sort-Object -Descending { Get-VersionSortKey $_.Tag }
        ))

    # In the order of the table, and links no dependency claims last
    Set-Variable -Option Constant Owners ([String[]]@(@($Updates | ForEach-Object { $_.Name }) + ''))

    # Grouped by where they point, as the three are read differently: another site's changelog,
    # a list of commits, or release notes, which are quoted in full further down
    Set-Variable -Option Constant Sections ([Ordered]@{
            Other   = 'Other sites'
            Commits = 'GitHub commits'
            Release = 'GitHub releases and tags'
        })

    if ($Links.Count -gt 0) {
        [Void]$Text.Append("`n## Links`n")
    }

    foreach ($Kind in $Sections.Keys) {
        [PSObject[]]$KindLinks = @($Links | Where-Object { $_.Kind -eq $Kind })
        if ($KindLinks.Count -eq 0) {
            continue
        }

        [Void]$Text.Append("`n### $($Sections[$Kind])`n`n")

        foreach ($Owner in $Owners) {
            [String[]]$Formatted = @($KindLinks | Where-Object { $_.Owner -eq $Owner } | ForEach-Object {
                    if ($_.Label) { "[$($_.Label)]($($_.Url))" } else { "<$($_.Url)>" }
                })

            if ($Formatted.Count -gt 0) {
                [String]$Prefix = if ($Owner) { "${Owner}: " } else { '' }
                [Void]$Text.Append("- $Prefix$($Formatted -join ', ')`n")
            }
        }
    }

    [PSObject[]]$Releases = @($Links | Where-Object { $_.Kind -eq 'Release' })
    if ($Releases.Count -eq 0) {
        return $Text.ToString().TrimEnd()
    }

    [Void]$Text.Append("`n## Release notes`n")

    [Collections.Generic.List[PSObject]]$Skipped = @()

    # In the order of the table too, so the notes most likely to be cut for length are the last ones
    Set-Variable -Option Constant Repositories ([String[]]@($Owners | ForEach-Object {
                [String]$Owner = $_
                $Releases | Where-Object { $_.Owner -eq $Owner } | ForEach-Object { $_.Repository }
            } | Select-Object -Unique))

    foreach ($Repository in $Repositories) {
        [PSObject[]]$Versions = @($Releases | Where-Object { $_.Repository -eq $Repository })
        [PSObject]$Update = $Updates | Where-Object { $_.Name -eq $Versions[0].Owner } | Select-Object -First 1
        [String]$Summary = if ($Update) {
            "$($Update.Name) $(Format-DependencyVersion $Update.From) $Arrow $(Format-DependencyVersion $Update.To)"
        } else {
            $Repository
        }

        [Bool]$IsOpen = $False

        foreach ($Release in $Versions) {
            if ($Skipped.Count -gt 0) {
                $Skipped.Add($Release)
                continue
            }

            # Deliberately untyped: a [String] would turn "no release for this tag" ($Null) into ''
            $Notes = Get-ReleaseNotes $Release.Repository $Release.Tag $GitHubToken
            [String]$Content = if ($Null -eq $Notes) {
                '_No release notes are published for this version._'
            } elseif (-not $Notes.Trim()) {
                '_This version was released without notes._'
            } else {
                Format-ReleaseNotes $Notes $Release.Repository
            }

            [String]$Section = "### [$($Release.Tag)]($($Release.Url))`n`n$Content`n`n"
            [String]$Opening = if ($IsOpen) { '' } else { "`n<details>`n<summary>$Summary</summary>`n`n" }

            if ($Text.Length + $Opening.Length + $Section.Length + "</details>`n".Length -gt $Budget) {
                $Skipped.Add($Release)
                continue
            }

            [Void]$Text.Append($Opening).Append($Section)
            $IsOpen = $True
        }

        if ($IsOpen) {
            [Void]$Text.Append("</details>`n")
        }
    }

    if ($Skipped.Count -gt 0) {
        [Void]$Text.Append("`nThe notes for these versions did not fit in the description:`n`n")
        foreach ($Release in $Skipped) {
            [String]$Prefix = if ($Release.Owner) { "$($Release.Owner) " } else { '' }
            [Void]$Text.Append("- $Prefix[$($Release.Tag)]($($Release.Url))`n")
        }
    }

    return $Text.ToString().TrimEnd()
}
