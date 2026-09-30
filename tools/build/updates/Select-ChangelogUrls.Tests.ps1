BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Select-ChangelogUrls' {
    It 'Should keep the releases up to the target, newest first as given' {
        [String[]]$Result = @(Select-ChangelogUrls @(
                'https://github.com/pbatard/rufus/releases/tag/v4.18',
                'https://github.com/pbatard/rufus/releases/tag/v4.17',
                'https://github.com/pbatard/rufus/releases/tag/v4.16'
            ) 'v4.18' 'v4.17')

        $Result | Should -BeExactly @(
            'https://github.com/pbatard/rufus/releases/tag/v4.17',
            'https://github.com/pbatard/rufus/releases/tag/v4.16'
        )
    }

    It 'Should compare with the target instead of the latest version: <Case>' -ForEach @(
        @{
            Case     = 'commits'
            Url      = 'https://github.com/cschneegans/unattend-generator/compare/538f930aeea9c3d51fdd0b4822e2d076fef999e8...97c1141d51a9cdae6831107cb3311c2f9eb8121b'
            Latest   = '97c1141d51a9cdae6831107cb3311c2f9eb8121b'
            Target   = 'dcede27a0000000000000000000000000000000'
            Expected = 'https://github.com/cschneegans/unattend-generator/compare/538f930aeea9c3d51fdd0b4822e2d076fef999e8...dcede27a0000000000000000000000000000000'
        }
        @{
            Case     = 'tags'
            Url      = 'https://github.com/bmrf/tron/compare/v12.0.6...v12.0.8'
            Latest   = 'v12.0.8'
            Target   = 'v12.0.7'
            Expected = 'https://github.com/bmrf/tron/compare/v12.0.6...v12.0.7'
        }
        @{
            Case     = 'GitLab'
            Url      = 'https://gitlab.com/systemrescue/systemrescue-sources/-/compare/13.02...13.04'
            Latest   = '13.04'
            Target   = '13.03'
            Expected = 'https://gitlab.com/systemrescue/systemrescue-sources/-/compare/13.02...13.03'
        }
    ) {
        Select-ChangelogUrls @($Url) $Latest $Target | Should -BeExactly $Expected
    }

    It 'Should keep a page that names no version' {
        Select-ChangelogUrls @('https://www.oo-software.com/en/shutup10') '3.7.1140' '3.6.1135' | Should -BeExactly 'https://www.oo-software.com/en/shutup10'
    }

    It 'Should keep only the target release when the tags do not read as versions' {
        [String[]]$Result = @(Select-ChangelogUrls @(
                'https://github.com/owner/tool/releases/tag/release-b',
                'https://github.com/owner/tool/releases/tag/release-a'
            ) 'release-b' 'release-a')

        $Result | Should -BeExactly @('https://github.com/owner/tool/releases/tag/release-a')
    }

    It 'Should return nothing for no links' {
        @(Select-ChangelogUrls @() 'v2' 'v1').Count | Should -Be 0
    }
}
