BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'
    . '.\tools\common\types.ps1'
    . '.\tools\common\Read-JsonFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestUrlsFile ([String]'TEST_URLS_FILE')
    Set-Variable -Option Constant TestChecksum ([String]'ABCDEF0123456789')

    Set-Variable -Option Constant TestUrlsTemplate (
        [PSCustomObject]@{
            URL_TEST_DEPENDENCY_NAME = 'https://example.com/v{VERSION}/test-{VERSION}.zip'
            URL_STATIC_DEPENDENCY    = 'https://example.com/static.zip'
            URL_INSECURE_DEPENDENCY  = 'http://example.com/{VERSION}.zip'
        }
    )
}

Describe 'Update-DependencyChecksum' {
    BeforeEach {
        Mock Read-JsonFile { return $TestUrlsTemplate }
        Mock Write-LogInfo {}
        Mock Out-Failure {}
        Mock Invoke-WebRequest {}
        Mock Get-FileHash { return @{ Hash = $TestChecksum } }

        [Dependency]$TestDependency = @{ name = 'test dependency-name'; version = 'v2.0.0'; source = 'GitHub' }
    }

    It 'Should record the checksum of the new version download' {
        Update-DependencyChecksum $TestDependency $TestUrlsFile | Should -BeTrue

        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 1 -ParameterFilter { $Path -eq $TestUrlsFile }
        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1 -ParameterFilter {
            $Uri -eq 'https://example.com/v2.0.0/test-2.0.0.zip' -and
            $UseBasicParsing -eq $True -and
            $OutFile
        }
        Should -Invoke Get-FileHash -Exactly 1
        Should -Invoke Get-FileHash -Exactly 1 -ParameterFilter { $Algorithm -eq 'SHA256' }
        Should -Invoke Out-Failure -Exactly 0

        $TestDependency.sha256 | Should -BeExactly $TestChecksum.ToLower()
    }

    It 'Should replace a previously recorded checksum' {
        $TestDependency | Add-Member -NotePropertyName 'sha256' -NotePropertyValue 'old'

        Update-DependencyChecksum $TestDependency $TestUrlsFile | Should -BeTrue

        $TestDependency.sha256 | Should -BeExactly $TestChecksum.ToLower()
    }

    It 'Should skip dependencies without a URL' {
        [Dependency]$NoUrlDependency = @{ name = 'no url'; version = '1.0.0'; source = 'GitHub' }

        Update-DependencyChecksum $NoUrlDependency $TestUrlsFile | Should -BeTrue

        Should -Invoke Invoke-WebRequest -Exactly 0
        $NoUrlDependency.PSObject.Properties['sha256'] | Should -BeNullOrEmpty
    }

    It 'Should skip dependencies with an unversioned URL' {
        [Dependency]$StaticDependency = @{ name = 'static-dependency'; version = '1.0.0'; source = 'URL' }

        Update-DependencyChecksum $StaticDependency $TestUrlsFile | Should -BeTrue

        Should -Invoke Invoke-WebRequest -Exactly 0
        $StaticDependency.PSObject.Properties['sha256'] | Should -BeNullOrEmpty
    }

    It 'Should refuse to download over plain HTTP' {
        [Dependency]$InsecureDependency = @{ name = 'insecure dependency'; version = '1.0.0'; source = 'URL' }

        Update-DependencyChecksum $InsecureDependency $TestUrlsFile | Should -BeFalse

        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Invoke-WebRequest failure' {
        Mock Invoke-WebRequest { throw $TestException }

        Update-DependencyChecksum $TestDependency $TestUrlsFile | Should -BeFalse

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Get-FileHash -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        $TestDependency.PSObject.Properties['sha256'] | Should -BeNullOrEmpty
    }

    It 'Should handle Get-FileHash failure' {
        Mock Get-FileHash { throw $TestException }

        Update-DependencyChecksum $TestDependency $TestUrlsFile | Should -BeFalse

        Should -Invoke Get-FileHash -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        $TestDependency.PSObject.Properties['sha256'] | Should -BeNullOrEmpty
    }

    It 'Should handle Read-JsonFile failure' {
        Mock Read-JsonFile { throw $TestException }

        { Update-DependencyChecksum $TestDependency $TestUrlsFile } | Should -Throw $TestException

        Should -Invoke Invoke-WebRequest -Exactly 0
    }
}
