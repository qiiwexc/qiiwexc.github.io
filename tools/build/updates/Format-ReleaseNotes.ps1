function Format-ReleaseNotes {
    param(
        [Parameter(Position = 0, Mandatory)][AllowEmptyString()][String]$Notes,
        [Parameter(Position = 1, Mandatory)][ValidateNotNullOrEmpty()][String]$Repository,
        [Parameter(Position = 2)][Int]$HeadingOffset = 3
    )

    # Quoted into this repository's pull request, the notes would otherwise act here: a bare '#123'
    # links to this repository's issue 123, '@name' notifies that person, and a link to an upstream
    # issue adds a backlink to it. GitHub ignores references inside code and link text, and links
    # through redirect.github.com leave no backlink, which is how Dependabot quotes notes too
    Set-Variable -Option Constant InlinePattern ([String](@(
                '(?<code>(?<ticks>`+)(?!`).*?(?<!`)\k<ticks>(?!`))',
                '(?<link>!?\[(?:[^\[\]]|\[[^\[\]]*\])*\]\([^)\s]*(?:\s+"[^"]*")?\))',
                '(?<anchor><a\s[^>]*>.*?</a>)',
                '(?<url>https?://github\.com/[\w.-]+/[\w.-]+/(?:issues|pull|discussions)/\d+)',
                '(?<mention>(?<![\w@/.`-])@[A-Za-z0-9](?:[A-Za-z0-9]|-(?=[A-Za-z0-9])){0,38}(?![\w/-]))',
                '(?<reference>(?<![\w/&#.`-])(?:[A-Za-z0-9][\w.-]*/[\w.-]+)?#\d+\b)'
            ) -join '|'))
    Set-Variable -Option Constant IssueUrlPattern ([String]'https?://github\.com/(?=[\w.-]+/[\w.-]+/(?:issues|pull|discussions)/\d+)')
    Set-Variable -Option Constant RedirectUrl ([String]'https://redirect.github.com/')

    Set-Variable -Option Constant Evaluator ([Text.RegularExpressions.MatchEvaluator] {
            param([Text.RegularExpressions.Match]$Match)

            if ($Match.Groups['code'].Success) {
                return $Match.Value
            }
            if ($Match.Groups['link'].Success -or $Match.Groups['anchor'].Success -or $Match.Groups['url'].Success) {
                return $Match.Value -replace $IssueUrlPattern, $RedirectUrl
            }
            if ($Match.Groups['mention'].Success) {
                return "[$($Match.Value)](https://github.com/$($Match.Value.Substring(1)))"
            }

            [String[]]$Parts = $Match.Value.Split('#')
            [String]$Target = if ($Parts[0]) { $Parts[0] } else { $Repository }
            return "[$($Match.Value)]($RedirectUrl$Target/issues/$($Parts[1]))"
        })

    # HTML comments never render, and some projects keep whole drafting notes in them
    [String]$Text = [Regex]::Replace($Notes.Replace("`r`n", "`n").Replace("`r", "`n"), '(?s)<!--.*?-->', '')

    [Collections.Generic.List[String]]$Lines = @()
    [String]$Fence = ''

    foreach ($Line in $Text.Split("`n")) {
        if ($Fence) {
            if ($Line.TrimStart().StartsWith($Fence)) {
                $Fence = ''
            }
            $Lines.Add($Line)
            continue
        }

        if ($Line -match '^\s{0,3}(`{3,}|~{3,})') {
            $Fence = $Matches[1]
            $Lines.Add($Line)
            continue
        }

        # Headings move down to sit under the per-version heading the description puts above them
        if ($Line -match '^(#{1,6})(\s.*)?$') {
            [Int]$Level = [Math]::Min(6, $Matches[1].Length + $HeadingOffset)
            $Line = ('#' * $Level) + $Matches[2]
        }

        $Lines.Add([Regex]::Replace($Line, $InlinePattern, $Evaluator))
    }

    return ($Lines -join "`n").Trim("`n", ' ', "`t")
}
