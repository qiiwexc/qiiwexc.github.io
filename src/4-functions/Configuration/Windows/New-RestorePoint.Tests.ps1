BeforeAll {
    # Untyped stubs so Pester can mock commands that only Windows PowerShell has, on any host
    function Enable-ComputerRestore { [CmdletBinding()] param([String[]]$Drive) }
    function Get-ComputerRestorePoint { [CmdletBinding()] param() }
    function Checkpoint-Computer { [CmdletBinding()] param([String]$Description, [String]$RestorePointType) }

    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\App lifecycle\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    function New-TestRestorePoint {
        param(
            [Parameter(Position = 0, Mandatory)][UInt32]$SequenceNumber,
            [Parameter(Position = 1, Mandatory)][DateTime]$Created
        )

        return [PSCustomObject]@{
            SequenceNumber = $SequenceNumber
            Description    = "TEST_RESTORE_POINT_$SequenceNumber"
            CreationTime   = [Management.ManagementDateTimeConverter]::ToDmtfDateTime($Created)
        }
    }

    Set-Variable -Option Constant TestOldPoint ([PSObject](New-TestRestorePoint 7 (Get-Date).AddDays(-3)))
    Set-Variable -Option Constant TestOlderPoint ([PSObject](New-TestRestorePoint 6 (Get-Date).AddDays(-10)))
    Set-Variable -Option Constant TestNewPoint ([PSObject](New-TestRestorePoint 8 (Get-Date)))
}

Describe 'New-RestorePoint' {
    BeforeEach {
        # What Get-ComputerRestorePoint lists: the points there are, and the one Checkpoint-Computer adds
        $script:Points = [Collections.Generic.List[PSObject]]@($TestOlderPoint, $TestOldPoint)
    }

    BeforeAll {
        Mock Get-ItemProperty { return [PSCustomObject]@{ RPSessionInterval = 1 } }
        Mock Enable-ComputerRestore {}
        Mock Get-ComputerRestorePoint { return $script:Points.ToArray() }
        Mock Checkpoint-Computer { $script:Points.Add($TestNewPoint) }
        Mock Write-LogInfo {}
        Mock Out-Success {}
    }

    It 'Should create a restore point' {
        New-RestorePoint

        Should -Invoke Enable-ComputerRestore -Exactly 0
        Should -Invoke Checkpoint-Computer -Exactly 1
        Should -Invoke Checkpoint-Computer -Exactly 1 -ParameterFilter {
            $Description -eq 'Before qiiwexc Windows configuration' -and
            $RestorePointType -eq 'MODIFY_SETTINGS'
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should turn System Restore on for the system drive when it is off' {
        Mock Get-ItemProperty { return [PSCustomObject]@{ RPSessionInterval = 0 } }

        New-RestorePoint

        Should -Invoke Enable-ComputerRestore -Exactly 1
        Should -Invoke Enable-ComputerRestore -Exactly 1 -ParameterFilter { $Drive -eq "$env:SystemDrive\" }
        Should -Invoke Write-LogInfo -Exactly 1 -ParameterFilter { $Message -match 'System Restore is off' }
        Should -Invoke Checkpoint-Computer -Exactly 1
    }

    It 'Should turn System Restore on when its settings say nothing' {
        Mock Get-ItemProperty { return [PSCustomObject]@{} }

        New-RestorePoint

        Should -Invoke Enable-ComputerRestore -Exactly 1
        Should -Invoke Checkpoint-Computer -Exactly 1
    }

    It 'Should create the first restore point there is' {
        $script:Points.Clear()

        New-RestorePoint

        Should -Invoke Checkpoint-Computer -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should use a restore point under a day old, which Windows would not replace' {
        $script:Points.Add((New-TestRestorePoint 8 (Get-Date).AddHours(-2)))

        New-RestorePoint

        Should -Invoke Checkpoint-Computer -Exactly 0
        Should -Invoke Write-LogInfo -Exactly 1 -ParameterFilter { $Message -match "Using restore point 'TEST_RESTORE_POINT_8'" }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should fail when Windows skips the restore point it was asked for' {
        Mock Checkpoint-Computer {}

        { New-RestorePoint } | Should -Throw 'Windows did not create one'

        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Enable-ComputerRestore failure' {
        Mock Get-ItemProperty { return [PSCustomObject]@{ RPSessionInterval = 0 } }
        Mock Enable-ComputerRestore { throw $TestException }

        { New-RestorePoint } | Should -Throw $TestException

        Should -Invoke Checkpoint-Computer -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Checkpoint-Computer failure' {
        Mock Checkpoint-Computer { throw $TestException }

        { New-RestorePoint } | Should -Throw $TestException

        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Get-ItemProperty failure' {
        Mock Get-ItemProperty { throw $TestException }

        { New-RestorePoint } | Should -Throw $TestException

        Should -Invoke Checkpoint-Computer -Exactly 0
    }
}
