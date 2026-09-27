BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\common\types.ps1"

    Set-Variable -Option Constant TestUrlsTemplate ([PSCustomObject]@{
            URL_RUFUS      = 'https://example.com/rufus-{VERSION}.exe'
            URL_VENTOY     = 'https://example.com/ventoy-{VERSION}.zip'
            URL_SDI        = 'https://example.com/sdi-{VERSION}.7z'
            URL_CPU_Z      = 'https://example.com/cpu-z-{VERSION}.zip'
            URL_TRONSCRIPT = 'https://example.com/tronscript'
        })

    Set-Variable -Option Constant TestOldDeps ([Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.11'; source = 'GitHub'; repository = 'pbatard/rufus'; opensPullRequest = $True }
            @{ name = 'WinUtil'; version = '26.01.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil'; opensPullRequest = $True }
            @{ name = 'SystemRescue'; version = '12.02'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources'; opensPullRequest = $False }
            @{ name = 'SDI'; version = '1.25.0'; source = 'URL'; opensPullRequest = $False }
            @{ name = 'TronScript'; version = 'v12.0.5'; source = 'GitHub'; repository = 'bmrf/tron'; opensPullRequest = $False }
        ))
}

Describe 'Compare-Dependencies' {
    It 'Should detect no changes when versions are identical' {
        $Result = Compare-Dependencies $TestOldDeps $TestOldDeps $TestUrlsTemplate

        $Result.Updates.Count | Should -Be 0
    }

    It 'Should detect GitHub dependency update with URL change' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.12'; source = 'GitHub'; repository = 'pbatard/rufus'; opensPullRequest = $True }
            @{ name = 'WinUtil'; version = '26.01.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil'; opensPullRequest = $True }
            @{ name = 'SystemRescue'; version = '12.02'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources'; opensPullRequest = $False }
            @{ name = 'SDI'; version = '1.25.0'; source = 'URL'; opensPullRequest = $False }
            @{ name = 'TronScript'; version = 'v12.0.5'; source = 'GitHub'; repository = 'bmrf/tron'; opensPullRequest = $False }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        $Result.Updates.Name | Should -BeExactly @('Rufus')
        $Result.Updates.From | Should -BeExactly @('v4.11')
        $Result.Updates.To | Should -BeExactly @('v4.12')
        $Result.Updates[0].UrlChange | Should -Be $True
        $Result.Updates[0].ToolChange | Should -Be $False
        $Result.Updates[0].OpensPullRequest | Should -Be $True
        $Result.Updates[0].Dependency.repository | Should -BeExactly 'pbatard/rufus'
    }

    It 'Should detect GitLab dependency update without URL change' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.11'; source = 'GitHub'; repository = 'pbatard/rufus'; opensPullRequest = $True }
            @{ name = 'WinUtil'; version = '26.01.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil'; opensPullRequest = $True }
            @{ name = 'SystemRescue'; version = '12.03'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources'; opensPullRequest = $False }
            @{ name = 'SDI'; version = '1.25.0'; source = 'URL'; opensPullRequest = $False }
            @{ name = 'TronScript'; version = 'v12.0.5'; source = 'GitHub'; repository = 'bmrf/tron'; opensPullRequest = $False }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        $Result.Updates.Name | Should -BeExactly @('SystemRescue')
        $Result.Updates.From | Should -BeExactly @('12.02')
        $Result.Updates.To | Should -BeExactly @('12.03')
        $Result.Updates[0].UrlChange | Should -Be $False
        $Result.Updates[0].OpensPullRequest | Should -Be $False
    }

    It 'Should detect URL dependency update with URL change' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.11'; source = 'GitHub'; repository = 'pbatard/rufus'; opensPullRequest = $True }
            @{ name = 'WinUtil'; version = '26.01.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil'; opensPullRequest = $True }
            @{ name = 'SystemRescue'; version = '12.02'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources'; opensPullRequest = $False }
            @{ name = 'SDI'; version = '1.26.0'; source = 'URL'; opensPullRequest = $False }
            @{ name = 'TronScript'; version = 'v12.0.5'; source = 'GitHub'; repository = 'bmrf/tron'; opensPullRequest = $False }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        $Result.Updates.Name | Should -BeExactly @('SDI')
        $Result.Updates.From | Should -BeExactly @('1.25.0')
        $Result.Updates.To | Should -BeExactly @('1.26.0')
        $Result.Updates[0].UrlChange | Should -Be $True
    }

    It 'Should not flag a URL change for a dependency without a URL key' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.11'; source = 'GitHub'; repository = 'pbatard/rufus'; opensPullRequest = $True }
            @{ name = 'WinUtil'; version = '26.02.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil'; opensPullRequest = $True }
            @{ name = 'SystemRescue'; version = '12.02'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources'; opensPullRequest = $False }
            @{ name = 'SDI'; version = '1.25.0'; source = 'URL'; opensPullRequest = $False }
            @{ name = 'TronScript'; version = 'v12.0.5'; source = 'GitHub'; repository = 'bmrf/tron'; opensPullRequest = $False }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        $Result.Updates.Name | Should -BeExactly @('WinUtil')
        $Result.Updates.From | Should -BeExactly @('26.01.01')
        $Result.Updates.To | Should -BeExactly @('26.02.01')
        $Result.Updates[0].UrlChange | Should -Be $False
    }

    It 'Should not flag a URL change when the URL has no version placeholder' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.11'; source = 'GitHub'; repository = 'pbatard/rufus'; opensPullRequest = $True }
            @{ name = 'WinUtil'; version = '26.01.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil'; opensPullRequest = $True }
            @{ name = 'SystemRescue'; version = '12.02'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources'; opensPullRequest = $False }
            @{ name = 'SDI'; version = '1.25.0'; source = 'URL'; opensPullRequest = $False }
            @{ name = 'TronScript'; version = 'v12.0.6'; source = 'GitHub'; repository = 'bmrf/tron'; opensPullRequest = $False }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        $Result.Updates.Name | Should -BeExactly @('TronScript')
        $Result.Updates.From | Should -BeExactly @('v12.0.5')
        $Result.Updates.To | Should -BeExactly @('v12.0.6')
        $Result.Updates[0].UrlChange | Should -Be $False
    }

    It 'Should detect multiple dependency updates' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.12'; source = 'GitHub'; repository = 'pbatard/rufus'; opensPullRequest = $True }
            @{ name = 'WinUtil'; version = '26.02.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil'; opensPullRequest = $True }
            @{ name = 'SystemRescue'; version = '12.03'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources'; opensPullRequest = $False }
            @{ name = 'SDI'; version = '1.26.0'; source = 'URL'; opensPullRequest = $False }
            @{ name = 'TronScript'; version = 'v12.0.6'; source = 'GitHub'; repository = 'bmrf/tron'; opensPullRequest = $False }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        $Result.Updates.Count | Should -Be 5
        $Result.Updates.Name | Should -Contain 'Rufus'
        $Result.Updates.Name | Should -Contain 'WinUtil'
        $Result.Updates.Name | Should -Contain 'SystemRescue'
        $Result.Updates.Name | Should -Contain 'SDI'
        $Result.Updates.Name | Should -Contain 'TronScript'
        @($Result.Updates | Where-Object { $_.UrlChange }).Name | Should -BeExactly @('Rufus', 'SDI')
        @($Result.Updates | Where-Object { $_.OpensPullRequest }).Name | Should -BeExactly @('Rufus', 'WinUtil')
    }

    It 'Should flag updates of the tools the CI runs: <Name>' -ForEach @(
        @{ Name = 'Pester' }
        @{ Name = 'PSScriptAnalyzer' }
    ) {
        $OldDeps = [Dependency[]]@(@{ name = $Name; version = '1.0.0'; source = 'GitHub'; repository = "test/$Name"; opensPullRequest = $True })
        $NewDeps = [Dependency[]]@(@{ name = $Name; version = '1.1.0'; source = 'GitHub'; repository = "test/$Name"; opensPullRequest = $True })

        $Result = Compare-Dependencies $OldDeps $NewDeps $TestUrlsTemplate

        $Result.Updates.Name | Should -BeExactly @($Name)
        $Result.Updates[0].ToolChange | Should -Be $True
        $Result.Updates[0].UrlChange | Should -Be $False
    }

    It 'Should not flag tool changes for other dependencies' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.12'; source = 'GitHub'; repository = 'pbatard/rufus'; opensPullRequest = $True }
            @{ name = 'WinUtil'; version = '26.02.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil'; opensPullRequest = $True }
            @{ name = 'SystemRescue'; version = '12.03'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources'; opensPullRequest = $False }
            @{ name = 'SDI'; version = '1.26.0'; source = 'URL'; opensPullRequest = $False }
            @{ name = 'TronScript'; version = 'v12.0.6'; source = 'GitHub'; repository = 'bmrf/tron'; opensPullRequest = $False }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        @($Result.Updates | Where-Object { $_.ToolChange }).Count | Should -Be 0
    }

    # Read from JSON, as the nightly reads the file: that is where a quoted "false" comes from
    It 'Should fail on an update that does not set opensPullRequest to true or false: <Case>' -ForEach @(
        @{ Case = 'missing'; Json = '{ "name": "Rufus", "version": "v4.12", "source": "GitHub" }' }
        @{ Case = 'null'; Json = '{ "name": "Rufus", "version": "v4.12", "source": "GitHub", "opensPullRequest": null }' }
        @{ Case = 'a string'; Json = '{ "name": "Rufus", "version": "v4.12", "source": "GitHub", "opensPullRequest": "false" }' }
        @{ Case = 'a number'; Json = '{ "name": "Rufus", "version": "v4.12", "source": "GitHub", "opensPullRequest": 1 }' }
    ) {
        $OldDeps = [Dependency[]]@(@{ name = 'Rufus'; version = 'v4.11'; source = 'GitHub'; opensPullRequest = $True })
        $NewDeps = [Dependency[]]@($Json | ConvertFrom-Json)

        { Compare-Dependencies $OldDeps $NewDeps $TestUrlsTemplate } | Should -Throw -ExpectedMessage 'Dependency ''Rufus'' must set ''opensPullRequest'' to true or false'
    }

    It 'Should skip new dependencies not in old list' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.11'; source = 'GitHub'; repository = 'pbatard/rufus'; opensPullRequest = $True }
            @{ name = 'WinUtil'; version = '26.01.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil'; opensPullRequest = $True }
            @{ name = 'SystemRescue'; version = '12.02'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources'; opensPullRequest = $False }
            @{ name = 'SDI'; version = '1.25.0'; source = 'URL'; opensPullRequest = $False }
            @{ name = 'TronScript'; version = 'v12.0.5'; source = 'GitHub'; repository = 'bmrf/tron'; opensPullRequest = $False }
            # Without a flag: only a dependency that moved needs one
            @{ name = 'NewTool'; version = '1.0.0'; source = 'GitHub'; repository = 'test/new-tool' }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        $Result.Updates.Count | Should -Be 0
    }
}

Describe 'resources\dependencies.json' {
    It 'Should set opensPullRequest to true or false for every dependency' {
        $Dependencies = Get-Content "$PSScriptRoot\..\..\resources\dependencies.json" -Raw -Encoding UTF8 | ConvertFrom-Json

        $Dependencies |
            Where-Object { -not $_.PSObject.Properties['opensPullRequest'] -or $_.opensPullRequest -isnot [Bool] } |
            ForEach-Object { $_.name } |
            Should -BeNullOrEmpty
    }
}
