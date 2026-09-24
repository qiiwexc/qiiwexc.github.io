BeforeDiscovery {
    Set-Variable -Option Constant JsonFiles ([Hashtable[]]@(Get-ChildItem $PSScriptRoot -Recurse -Filter *.json | ForEach-Object { @{ Name = $_.Name; FullName = $_.FullName } }))
    Set-Variable -Option Constant RegFiles ([Hashtable[]]@(Get-ChildItem $PSScriptRoot -Recurse -Filter *.reg | ForEach-Object { @{ Name = $_.Name; FullName = $_.FullName } }))
}

BeforeAll {
    Set-Variable -Option Constant SourcePath ([String](Split-Path -Parent $PSScriptRoot))

    function Get-InvalidRegLines {
        param(
            [Parameter(Position = 0, Mandatory)][AllowEmptyString()][String[]]$Lines
        )

        # What a .reg file line may be. A value may carry a trailing '; comment', and a hex value
        # may continue on the next lines after a trailing backslash
        Set-Variable -Option Constant LinePatterns ([String[]]@(
                '^$',
                '^;',
                '^\[-?HKEY_(CURRENT_USER|LOCAL_MACHINE|CLASSES_ROOT|USERS|CURRENT_CONFIG)(\\[^\]]+)?\]$',
                '^("([^"\\]|\\.)*"|@)=(-|"([^"\\]|\\.)*"|dword:[0-9a-fA-F]{8}|hex(\([0-9a-fA-F]\))?:([0-9a-fA-F]{2}(,[0-9a-fA-F]{2})*,?)?)\s*(;.*)?$',
                '^("([^"\\]|\\.)*"|@)=hex(\([0-9a-fA-F]\))?:([0-9a-fA-F]{2},)+\s*\\$'
            ))
        Set-Variable -Option Constant ContinuationPattern ([String]'^\s+([0-9a-fA-F]{2},)*[0-9a-fA-F]{2},?\s*\\?$')

        [Bool]$IsContinuation = $False
        [Int]$LineNumber = 0

        foreach ($Line in $Lines) {
            $LineNumber++
            if ($IsContinuation) {
                [Bool]$IsValid = $Line -match $ContinuationPattern
            } else {
                [Bool]$IsValid = @($LinePatterns | Where-Object { $Line -match $_ }).Count -gt 0
            }
            if (-not $IsValid) {
                "${LineNumber}: $Line"
            }
            $IsContinuation = $Line.TrimEnd().EndsWith('\')
        }
    }
}

Describe 'Get-InvalidRegLines' {
    It 'Should accept <Line>' -ForEach @(
        @{ Line = '' }
        @{ Line = '; Comment' }
        @{ Line = '[HKEY_CURRENT_USER\Software\Test]' }
        @{ Line = '[-HKEY_LOCAL_MACHINE\SOFTWARE\Test]' }
        @{ Line = '"Name"=dword:00000001' }
        @{ Line = '"Name"=dword:00000001 ; Comment' }
        @{ Line = '"Name"="Value"' }
        @{ Line = '@="Value"' }
        @{ Line = '"Name"=-' }
        @{ Line = '"Name"=hex:2C,00,00,00' }
    ) {
        Get-InvalidRegLines @($Line) | Should -BeNullOrEmpty
    }

    It 'Should reject <Line>' -ForEach @(
        @{ Line = '"Name"=dword:0000000G' }
        @{ Line = '"Name"=dword:65534' }
        @{ Line = '"Name"=dwrod:00000001' }
        @{ Line = 'Name=dword:00000001' }
        @{ Line = '"Name"="Unterminated' }
        @{ Line = '[HKEY_CURENT_USER\Software\Test]' }
        @{ Line = '{CONFIG_PERSONALIZATION}' }
    ) {
        Get-InvalidRegLines @($Line) | Should -BeExactly "1: $Line"
    }

    It 'Should accept hex values continued on the next lines' {
        Get-InvalidRegLines @('"Name"=hex:2C,00,00,00,\', '  FF,FF,FF,FF,\', '  00,00') | Should -BeNullOrEmpty
    }

    It 'Should reject a continuation line that is not hex' {
        Get-InvalidRegLines @('"Name"=hex:2C,00,00,00,\', '"Other"=dword:00000001') | Should -BeExactly '2: "Other"=dword:00000001'
    }
}

Describe 'JSON config <Name>' -ForEach $JsonFiles {
    It 'Should parse' {
        { Get-Content -LiteralPath $FullName -Raw -Encoding UTF8 | ConvertFrom-Json } | Should -Not -Throw
    }
}

Describe 'Registry config <Name>' -ForEach $RegFiles {
    It 'Should only contain valid .reg lines' {
        Get-InvalidRegLines @(Get-Content -LiteralPath $FullName -Encoding UTF8) | Should -BeNullOrEmpty
    }
}

Describe 'Config references' {
    It 'Should embed every config the app refers to' {
        # Non-script configs are embedded as CONFIG_<FILE NAME> by tools/build/New-PowerShellScript.ps1;
        # script configs define their CONFIG_ constants themselves
        Set-Variable -Option Constant EmbeddedNames ([String[]]@(
                Get-ChildItem $PSScriptRoot -Recurse -File | Where-Object { $_.Extension -ne '.ps1' } | ForEach-Object {
                    'CONFIG_' + ($_.Name.Replace(' ', '_') -replace '\..{1,}$', '').ToUpper()
                }
                Get-ChildItem $PSScriptRoot -Recurse -Filter *.ps1 | Where-Object { $_.Name -notlike '*.Tests.ps1' } |
                    Select-String -Pattern 'Set-Variable -Option Constant (CONFIG_[A-Z0-9_]+)' | ForEach-Object { $_.Matches[0].Groups[1].Value }
            ))

        Set-Variable -Option Constant ReferencedNames ([String[]]@(
                Get-ChildItem $SourcePath -Recurse -Filter *.ps1 | Where-Object { $_.Name -notlike '*.Tests.ps1' } |
                    Select-String -Pattern '\$(CONFIG_[A-Z0-9_]+)' -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Groups[1].Value } |
                    Sort-Object -Unique
            ))

        $ReferencedNames | Should -Not -BeNullOrEmpty
        $ReferencedNames | Where-Object { $_ -notin $EmbeddedNames } | Should -BeNullOrEmpty
    }
}
