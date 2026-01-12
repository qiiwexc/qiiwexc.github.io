BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Invoke-CustomCommand.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
}

Describe 'Update-MicrosoftStoreApps' {
    BeforeEach {
        Mock Write-LogInfo { }
        Mock Invoke-CustomCommand { }
        Mock Out-Success { }
        Mock Write-LogException { }
    }

    It 'Should update Microsoft Store apps' {
        Update-MicrosoftStoreApps

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $Command -eq "Get-CimInstance MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap' | Invoke-CimMethod -MethodName 'UpdateScanMethod'" -and
            $Elevated -eq $True -and
            $HideWindow -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogException -Exactly 0
    }

    It 'Should handle Invoke-CustomCommand failure' {
        Mock Invoke-CustomCommand { throw $TestException }

        { Update-MicrosoftStoreApps } | Should -Not -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogException -Exactly 1
    }
}
