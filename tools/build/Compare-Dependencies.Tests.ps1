BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\types.ps1'

    Set-Variable -Option Constant TestUrlsTemplate ([PSCustomObject]@{
            URL_RUFUS      = 'https://example.com/rufus-{VERSION}.exe'
            URL_VENTOY     = 'https://example.com/ventoy-{VERSION}.zip'
            URL_SDI        = 'https://example.com/sdi-{VERSION}.7z'
            URL_CPU_Z      = 'https://example.com/cpu-z-{VERSION}.zip'
            URL_TRONSCRIPT = 'https://example.com/tronscript'
        })

    Set-Variable -Option Constant TestOldDeps ([Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.11'; source = 'GitHub'; repository = 'pbatard/rufus' }
            @{ name = 'WinUtil'; version = '26.01.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil' }
            @{ name = 'SystemRescue'; version = '12.02'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources' }
            @{ name = 'SDI'; version = '1.25.0'; source = 'URL' }
            @{ name = 'TronScript'; version = 'v12.0.5'; source = 'GitHub'; repository = 'bmrf/tron' }
        ))
}

Describe 'Compare-Dependencies' {
    It 'Should detect no changes when versions are identical' {
        $Result = Compare-Dependencies $TestOldDeps $TestOldDeps $TestUrlsTemplate

        $Result.UpdatedNames.Count | Should -Be 0
        $Result.UpdateDetails.Count | Should -Be 0
        $Result.HasUrlChange | Should -Be $False
    }

    It 'Should detect GitHub dependency update with URL change' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.12'; source = 'GitHub'; repository = 'pbatard/rufus' }
            @{ name = 'WinUtil'; version = '26.01.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil' }
            @{ name = 'SystemRescue'; version = '12.02'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources' }
            @{ name = 'SDI'; version = '1.25.0'; source = 'URL' }
            @{ name = 'TronScript'; version = 'v12.0.5'; source = 'GitHub'; repository = 'bmrf/tron' }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        $Result.UpdatedNames | Should -BeExactly @('Rufus')
        $Result.UpdateDetails | Should -BeExactly @('Rufus: v4.11 -> v4.12')
        $Result.HasUrlChange | Should -Be $True
    }

    It 'Should detect GitLab dependency update without URL change' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.11'; source = 'GitHub'; repository = 'pbatard/rufus' }
            @{ name = 'WinUtil'; version = '26.01.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil' }
            @{ name = 'SystemRescue'; version = '12.03'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources' }
            @{ name = 'SDI'; version = '1.25.0'; source = 'URL' }
            @{ name = 'TronScript'; version = 'v12.0.5'; source = 'GitHub'; repository = 'bmrf/tron' }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        $Result.UpdatedNames | Should -BeExactly @('SystemRescue')
        $Result.UpdateDetails | Should -BeExactly @('SystemRescue: 12.02 -> 12.03')
        $Result.HasUrlChange | Should -Be $False
    }

    It 'Should detect URL dependency update with URL change' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.11'; source = 'GitHub'; repository = 'pbatard/rufus' }
            @{ name = 'WinUtil'; version = '26.01.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil' }
            @{ name = 'SystemRescue'; version = '12.02'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources' }
            @{ name = 'SDI'; version = '1.26.0'; source = 'URL' }
            @{ name = 'TronScript'; version = 'v12.0.5'; source = 'GitHub'; repository = 'bmrf/tron' }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        $Result.UpdatedNames | Should -BeExactly @('SDI')
        $Result.UpdateDetails | Should -BeExactly @('SDI: 1.25.0 -> 1.26.0')
        $Result.HasUrlChange | Should -Be $True
    }

    It 'Should set HasUrlChange to false for dependency without URL key' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.11'; source = 'GitHub'; repository = 'pbatard/rufus' }
            @{ name = 'WinUtil'; version = '26.02.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil' }
            @{ name = 'SystemRescue'; version = '12.02'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources' }
            @{ name = 'SDI'; version = '1.25.0'; source = 'URL' }
            @{ name = 'TronScript'; version = 'v12.0.5'; source = 'GitHub'; repository = 'bmrf/tron' }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        $Result.UpdatedNames | Should -BeExactly @('WinUtil')
        $Result.UpdateDetails | Should -BeExactly @('WinUtil: 26.01.01 -> 26.02.01')
        $Result.HasUrlChange | Should -Be $False
    }

    It 'Should set HasUrlChange to false when URL has no version placeholder' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.11'; source = 'GitHub'; repository = 'pbatard/rufus' }
            @{ name = 'WinUtil'; version = '26.01.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil' }
            @{ name = 'SystemRescue'; version = '12.02'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources' }
            @{ name = 'SDI'; version = '1.25.0'; source = 'URL' }
            @{ name = 'TronScript'; version = 'v12.0.6'; source = 'GitHub'; repository = 'bmrf/tron' }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        $Result.UpdatedNames | Should -BeExactly @('TronScript')
        $Result.UpdateDetails | Should -BeExactly @('TronScript: v12.0.5 -> v12.0.6')
        $Result.HasUrlChange | Should -Be $False
    }

    It 'Should detect multiple dependency updates' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.12'; source = 'GitHub'; repository = 'pbatard/rufus' }
            @{ name = 'WinUtil'; version = '26.02.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil' }
            @{ name = 'SystemRescue'; version = '12.03'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources' }
            @{ name = 'SDI'; version = '1.26.0'; source = 'URL' }
            @{ name = 'TronScript'; version = 'v12.0.6'; source = 'GitHub'; repository = 'bmrf/tron' }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        $Result.UpdatedNames.Count | Should -Be 5
        $Result.UpdatedNames | Should -Contain 'Rufus'
        $Result.UpdatedNames | Should -Contain 'WinUtil'
        $Result.UpdatedNames | Should -Contain 'SystemRescue'
        $Result.UpdatedNames | Should -Contain 'SDI'
        $Result.UpdatedNames | Should -Contain 'TronScript'
        $Result.UpdateDetails.Count | Should -Be 5
        $Result.HasUrlChange | Should -Be $True
    }

    It 'Should skip new dependencies not in old list' {
        $NewDeps = [Dependency[]]@(
            @{ name = 'Rufus'; version = 'v4.11'; source = 'GitHub'; repository = 'pbatard/rufus' }
            @{ name = 'WinUtil'; version = '26.01.01'; source = 'GitHub'; repository = 'ChrisTitusTech/winutil' }
            @{ name = 'SystemRescue'; version = '12.02'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources' }
            @{ name = 'SDI'; version = '1.25.0'; source = 'URL' }
            @{ name = 'TronScript'; version = 'v12.0.5'; source = 'GitHub'; repository = 'bmrf/tron' }
            @{ name = 'NewTool'; version = '1.0.0'; source = 'GitHub'; repository = 'test/new-tool' }
        )

        $Result = Compare-Dependencies $TestOldDeps $NewDeps $TestUrlsTemplate

        $Result.UpdatedNames.Count | Should -Be 0
        $Result.HasUrlChange | Should -Be $False
    }
}
