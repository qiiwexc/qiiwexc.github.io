BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\common\logger.ps1"
    . "$PSScriptRoot\..\..\common\types.ps1"

    . "$(Split-Path $PSCommandPath -Parent)\Set-NewVersion.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestDependencyName ([String]'TestDependency')
    Set-Variable -Option Constant TestDependencyUrl ([String]'https://example.com/test-dependency')
    Set-Variable -Option Constant TestDependencyRegex ([String]'Latest Version:\s*(\d+\.\d+\.\d+)')
    Set-Variable -Option Constant TestDependencyVersion ([String]'1.0.0')
    Set-Variable -Option Constant TestDependency (
        [PSObject]@{
            name    = $TestDependencyName
            url     = $TestDependencyUrl
            regex   = $TestDependencyRegex
            version = $TestDependencyVersion
        }
    )
}

Describe 'Update-WebDependency' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Set-NewVersion {}
        Mock Invoke-WebRequest {
            return @{
                Content = 'Some content... Latest Version: 2.0.0 ...more content'
            }
        }
    }

    It 'Should update to new version' {
        Update-WebDependency $TestDependency | Should -BeExactly @('https://example.com/test-dependency')

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1 -ParameterFilter {
            $Uri -eq $TestDependency.url -and
            $UseBasicParsing -eq $True -and
            $TimeoutSec -eq 30
        }
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency.name -eq $TestDependencyName -and
            $Dependency.version -eq $TestDependencyVersion -and
            $Dependency.url -eq $TestDependencyUrl -and
            $Dependency.regex -eq $TestDependencyRegex -and
            $LatestVersion -eq '2.0.0'
        }
    }

    It 'Should not update if version is the same' {
        Mock Invoke-WebRequest {
            return @{
                Content = 'Some content... Latest Version: 1.0.0 ...more content'
            }
        }

        Update-WebDependency $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should fail if new version was not identified' {
        Mock Invoke-WebRequest { return @{ Content = 'no new version' } }

        { Update-WebDependency $TestDependency } | Should -Throw "Failed to find version number from URL '$TestDependencyUrl'"

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should fail on empty content' {
        Mock Invoke-WebRequest { return @{} }

        { Update-WebDependency $TestDependency } | Should -Throw "No data fetched from URL '$TestDependencyUrl'"

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should fail on Invoke-WebRequest failure' {
        Mock Invoke-WebRequest { throw $TestException }

        { Update-WebDependency $TestDependency } | Should -Throw "Failed to fetch URL '$TestDependencyUrl': $TestException"

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should fail when the Content property access throws' {
        $ThrowingResponse = [PSCustomObject]@{}
        $ThrowingResponse | Add-Member -MemberType ScriptProperty -Name Content -Value { throw 'Content access failed' }
        Mock Invoke-WebRequest { return $ThrowingResponse }

        { Update-WebDependency $TestDependency } | Should -Throw "No data fetched from URL '$TestDependencyUrl'"

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should refuse to fetch non-HTTPS URLs' {
        Set-Variable -Option Constant HttpDependency (
            [PSObject]@{
                name    = $TestDependencyName
                url     = 'http://example.com/test-dependency'
                regex   = $TestDependencyRegex
                version = $TestDependencyVersion
            }
        )

        { Update-WebDependency $HttpDependency } | Should -Throw '*only HTTPS is allowed*'

        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should reject scraped versions with unsafe characters' {
        Mock Invoke-WebRequest {
            return @{
                Content = "Some content... Latest Version: 2.0.0'); Invoke-Expression 'calc' #..."
            }
        }
        Set-Variable -Option Constant LooseDependency (
            [PSObject]@{
                name    = $TestDependencyName
                url     = $TestDependencyUrl
                regex   = 'Latest Version:\s*(.{1,80})\.\.\.'
                version = $TestDependencyVersion
            }
        )

        { Update-WebDependency $LooseDependency } | Should -Throw "Scraped version for '$TestDependencyName' looks unsafe*"

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should report HTTP status code on WebRequest failure with response' {
        $MockResponse = [PSCustomObject]@{ StatusCode = [System.Net.HttpStatusCode]::NotFound }
        $MockException = [System.Net.WebException]::new('The remote server returned an error')
        $MockException | Add-Member -MemberType NoteProperty -Name Response -Value $MockResponse -Force

        Mock Invoke-WebRequest { throw $MockException }

        { Update-WebDependency $TestDependency } | Should -Throw "Failed to fetch URL '$TestDependencyUrl': HTTP 404 NotFound"

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }
}
