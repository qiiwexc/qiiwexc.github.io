BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestClassName ([string]'MDM_EnterpriseModernAppManagement_AppManagement01')
    Set-Variable -Option Constant TestNamespace ([string]'root\cimv2\mdm\dmmap')
    Set-Variable -Option Constant TestAppManagement ([CimInstance]::new($TestClassName, $TestNamespace))
}

Describe 'Update-MicrosoftStoreApps' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Get-CimInstance { return $TestAppManagement }
        Mock Invoke-CimMethod {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should update Microsoft Store apps' {
        Update-MicrosoftStoreApps

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-CimInstance -Exactly 1
        Should -Invoke Get-CimInstance -Exactly 1 -ParameterFilter {
            $ClassName -eq $TestClassName -and
            $Namespace -eq $TestNamespace
        }
        Should -Invoke Invoke-CimMethod -Exactly 1
        Should -Invoke Invoke-CimMethod -Exactly 1 -ParameterFilter {
            $InputObject -eq $TestAppManagement -and
            $MethodName -eq 'UpdateScanMethod'
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Get-CimInstance failure' {
        Mock Get-CimInstance { throw $TestException }

        Update-MicrosoftStoreApps

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-CimInstance -Exactly 1
        Should -Invoke Invoke-CimMethod -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Invoke-CimMethod failure' {
        Mock Invoke-CimMethod { throw $TestException }

        Update-MicrosoftStoreApps

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-CimInstance -Exactly 1
        Should -Invoke Invoke-CimMethod -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
