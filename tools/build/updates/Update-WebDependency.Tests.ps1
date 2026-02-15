BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'
    . '.\tools\common\types.ps1'

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
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Out-Failure {}
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
        Should -Invoke Out-Failure -Exactly 0
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
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should not update if new version was not identified' {
        Mock Invoke-WebRequest { return @{ Content = 'no new version' } }

        Update-WebDependency $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should handle empty content' {
        Mock Invoke-WebRequest { return @{} }

        Update-WebDependency $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }
    It 'Should handle Invoke-WebRequest failure' {
        Mock Invoke-WebRequest { throw $TestException }

        Update-WebDependency $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should report HTTP status code on WebRequest failure with response' {
        $MockResponse = [PSCustomObject]@{ StatusCode = [System.Net.HttpStatusCode]::NotFound }
        $MockException = [System.Net.WebException]::new('The remote server returned an error')
        $MockException | Add-Member -MemberType NoteProperty -Name Response -Value $MockResponse -Force

        Mock Invoke-WebRequest { throw $MockException }

        Update-WebDependency $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }
}
