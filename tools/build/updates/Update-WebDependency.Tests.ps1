BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'
    . "$(Split-Path $PSCommandPath -Parent)\Set-NewVersion.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestDependency (
        [Object]@{
            name    = 'TestDependency'
            url     = 'https://example.com/test-dependency'
            regex   = 'Latest Version:\s*([0-9\.]+)'
            version = '1.0.0'
        }
    )
}

Describe 'Update-WebDependency' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Write-LogError {}
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
            $UseBasicParsing -eq $True
        }
        Should -Invoke Write-LogError -Exactly 0
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency -eq $TestDependency -and
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
        Should -Invoke Write-LogError -Exactly 0
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should handle empty content' {
        Mock Invoke-WebRequest { return @{ } }

        Update-WebDependency $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Write-LogError -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }
    It 'Should handle Invoke-WebRequest failure' {
        Mock Invoke-WebRequest { throw $TestException }

        { Update-WebDependency $TestDependency } | Should -Throw

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Write-LogError -Exactly 0
        Should -Invoke Set-NewVersion -Exactly 0
    }
}
