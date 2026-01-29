BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Get-ExecutableName' -Tag 'WIP' {
    BeforeEach {
        [Bool]$OS_64_BIT = $True
    }

    It 'Should return default executable name for unknown zip file' {
        Get-ExecutableName 'SomeApp.zip' 'SomeApp' | Should -BeExactly 'SomeApp.exe'
    }

    It 'Should return Office Installer executable on 64-bit OS' {
        Get-ExecutableName 'Office_Installer.zip' 'Office_Installer' | Should -BeExactly 'Office Installer.exe'
    }

    It 'Should return Office Installer x86 executable on 32-bit OS' {
        [Bool]$OS_64_BIT = $False
        Get-ExecutableName 'Office_Installer.zip' 'Office_Installer' | Should -BeExactly 'Office Installer x86.exe'
    }

    It 'Should return CPU-Z x64 executable on 64-bit OS' {
        Get-ExecutableName 'cpu-z_1.2.3.zip' 'cpu-z_1.2.3' | Should -BeExactly 'cpu-z_1.2.3\cpuz_x64.exe'
    }

    It 'Should return CPU-Z x32 executable on 32-bit OS' {
        [Bool]$OS_64_BIT = $False
        Get-ExecutableName 'cpu-z_1.2.3.zip' 'cpu-z_1.2.3' | Should -BeExactly 'cpu-z_1.2.3\cpuz_x32.exe'
    }

    It 'Should return SDI64-drv executable on 64-bit OS' {
        Get-ExecutableName 'SDI_1.2.3.zip' 'SDI_1.2.3' | Should -BeExactly 'SDI_1.2.3\SDI64-drv.exe'
    }

    It 'Should return SDI-drv executable on 32-bit OS' {
        [Bool]$OS_64_BIT = $False
        Get-ExecutableName 'SDI_1.2.3.zip' 'SDI_1.2.3' | Should -BeExactly 'SDI_1.2.3\SDI-drv.exe'
    }

    It 'Should return Ventoy2Disk executable' {
        Get-ExecutableName 'ventoy_1.2.3.zip' 'ventoy_1.2.3' | Should -BeExactly 'ventoy_1.2.3\ventoy_1.2.3\Ventoy2Disk.exe'
    }

    It 'Should return Victoria executable' {
        Get-ExecutableName 'Victoria_1.2.3.zip' 'Victoria_1.2.3' | Should -BeExactly 'Victoria_1.2.3\Victoria_1.2.3\Victoria.exe'
    }
}
