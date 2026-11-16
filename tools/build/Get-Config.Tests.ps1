BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\common\types.ps1"
    . "$PSScriptRoot\..\common\Progressbar.ps1"
    . "$PSScriptRoot\..\common\Read-JsonFile.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestResourcesPath ([String]'TEST_RESOURCES_PATH')
    Set-Variable -Option Constant TestVersion ([Version]'1.2.3')

    Set-Variable -Option Constant TestDependencies (
        [Dependency[]]@(
            @{name = 'test dependency-name 1'; version = 'v1.0.0' },
            @{name = 'test dependency-name 2'; version = '2.0.0' }
        )
    )
    Set-Variable -Option Constant TestUrlsTemplate (
        [PSCustomObject]@{
            URL_TEST_DEPENDENCY_NAME_1 = 'https://example.com/{VERSION}/download'
            URL_TEST_DEPENDENCY_NAME_2 = 'https://example.com/file-{VERSION}.zip'
            URL_STATIC                 = 'https://example.com/static'
        }
    )
}

Describe 'Get-Config' {
    BeforeAll {
        Mock New-Activity {}
        Mock Read-JsonFile { return $TestDependencies } -ParameterFilter { $Path -match 'dependencies' }
        Mock Read-JsonFile { return $TestUrlsTemplate } -ParameterFilter { $Path -match 'urls' }
        Mock Write-ActivityCompleted {}
    }

    It 'Should load config with resolved URLs and project version' {
        Set-Variable -Option Constant Result (Get-Config $TestResourcesPath $TestVersion)

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 2
        Should -Invoke Read-JsonFile -Exactly 1 -ParameterFilter { $Path -eq "$TestResourcesPath\dependencies.json" }
        Should -Invoke Read-JsonFile -Exactly 1 -ParameterFilter { $Path -eq "$TestResourcesPath\urls.json" }
        Should -Invoke Write-ActivityCompleted -Exactly 1

        $Result.URL_TEST_DEPENDENCY_NAME_1 | Should -BeExactly 'https://example.com/1.0.0/download'
        $Result.URL_TEST_DEPENDENCY_NAME_2 | Should -BeExactly 'https://example.com/file-2.0.0.zip'
        $Result.URL_STATIC | Should -BeExactly 'https://example.com/static'
        $Result.PROJECT_VERSION | Should -BeExactly $TestVersion
    }

    It 'Should handle dependencies Read-JsonFile failure' {
        Mock Read-JsonFile { throw $TestException } -ParameterFilter { $Path -match 'dependencies' }

        { Get-Config $TestResourcesPath $TestVersion } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle urls Read-JsonFile failure' {
        Mock Read-JsonFile { throw $TestException } -ParameterFilter { $Path -match 'urls' }

        { Get-Config $TestResourcesPath $TestVersion } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 2
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should skip dependencies with no matching URL key' {
        Set-Variable -Option Constant DepsWithNoUrl (
            [Dependency[]]@(
                @{name = 'test dependency-name 1'; version = 'v1.0.0' },
                @{name = 'test dependency-name 2'; version = '2.0.0' },
                @{name = 'no url dependency'; version = '3.0.0' }
            )
        )
        Mock Read-JsonFile { return $DepsWithNoUrl } -ParameterFilter { $Path -match 'dependencies' }

        Set-Variable -Option Constant Result (Get-Config $TestResourcesPath $TestVersion)

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 2
        Should -Invoke Write-ActivityCompleted -Exactly 1

        $Result.URL_TEST_DEPENDENCY_NAME_1 | Should -BeExactly 'https://example.com/1.0.0/download'
        $Result.URL_STATIC | Should -BeExactly 'https://example.com/static'
        $Result.PROJECT_VERSION | Should -BeExactly $TestVersion
        $Result.PSObject.Properties['URL_NO_URL_DEPENDENCY'] | Should -BeNullOrEmpty
    }

    It 'Should expose dependency checksums as SHA256 keys' {
        Set-Variable -Option Constant DepsWithChecksum (
            [Dependency[]]@(
                @{name = 'test dependency-name 1'; version = 'v1.0.0'; sha256 = 'abc123' },
                @{name = 'test dependency-name 2'; version = '2.0.0' }
            )
        )
        Mock Read-JsonFile { return $DepsWithChecksum } -ParameterFilter { $Path -match 'dependencies' }

        Set-Variable -Option Constant Result (Get-Config $TestResourcesPath $TestVersion)

        $Result.SHA256_TEST_DEPENDENCY_NAME_1 | Should -BeExactly 'abc123'
        $Result.PSObject.Properties['SHA256_TEST_DEPENDENCY_NAME_2'] | Should -BeNullOrEmpty
    }

    It 'Should throw when a URL has an unresolved VERSION placeholder' {
        Set-Variable -Option Constant DepsMissingOne (
            [Dependency[]]@(
                @{name = 'test dependency-name 1'; version = 'v1.0.0' }
            )
        )
        Mock Read-JsonFile { return $DepsMissingOne } -ParameterFilter { $Path -match 'dependencies' }
        # Fresh urls object: the shared $TestUrlsTemplate fixture is mutated by Get-Config in other tests
        Mock Read-JsonFile {
            return [PSCustomObject]@{
                URL_TEST_DEPENDENCY_NAME_1 = 'https://example.com/{VERSION}/download'
                URL_TEST_DEPENDENCY_NAME_2 = 'https://example.com/file-{VERSION}.zip'
            }
        } -ParameterFilter { $Path -match 'urls' }

        { Get-Config $TestResourcesPath $TestVersion } | Should -Throw '*URL_TEST_DEPENDENCY_NAME_2*'

        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should throw on config values with unsafe characters' {
        Set-Variable -Option Constant UnsafeUrls (
            [PSCustomObject]@{
                URL_TEST_DEPENDENCY_NAME_1 = 'https://example.com/{VERSION}/download'
                URL_TEST_DEPENDENCY_NAME_2 = 'https://example.com/file-{VERSION}.zip'
                URL_EVIL                   = "https://example.com/')); Invoke-Expression 'calc'; (('"
            }
        )
        Mock Read-JsonFile { return $UnsafeUrls } -ParameterFilter { $Path -match 'urls' }

        { Get-Config $TestResourcesPath $TestVersion } | Should -Throw '*URL_EVIL*'

        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}

# The app checks a download from the site against the hash pinned here, so a file replaced in the repository without
# its hash would pass every check and then fail the download in the next release
Describe 'resources\urls.json' {
    It 'Should pin the hash of each file the site publishes from the repository' {
        Set-Variable -Option Constant ProjectRoot ([String][IO.Path]::GetFullPath("$PSScriptRoot\..\.."))
        Set-Variable -Option Constant SiteUrl ([String]'https://qiiwexc.github.io/')
        Set-Variable -Option Constant Urls ([PSCustomObject](Get-Content "$ProjectRoot\resources\urls.json" -Raw -Encoding UTF8 | ConvertFrom-Json))

        Set-Variable -Option Constant Published ([PSObject[]]@($Urls.PSObject.Properties | Where-Object {
                    $_.Name -like 'URL_*' -and $_.Value.StartsWith($SiteUrl) -and $Urls.PSObject.Properties["SHA256_$($_.Name.Substring(4))"]
                }))

        $Published.Count | Should -BeGreaterThan 0
        foreach ($Url in $Published) {
            [String]$File = "$ProjectRoot\$($Url.Value.Substring($SiteUrl.Length).Replace('/', '\'))"
            (Get-FileHash -LiteralPath $File -Algorithm SHA256).Hash | Should -Be $Urls."SHA256_$($Url.Name.Substring(4))" -Because $Url.Name
        }
    }
}