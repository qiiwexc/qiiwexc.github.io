BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'
    . '.\tools\build\unattended\New-UnattendedBase.ps1'
    . '.\tools\build\unattended\Set-AppRemovalList.ps1'
    . '.\tools\build\unattended\Set-CapabilitiesRemovalList.ps1'
    . '.\tools\build\unattended\Set-FeaturesRemovalList.ps1'
    . '.\tools\build\unattended\Set-InlineFiles.ps1'
    . '.\tools\build\unattended\Set-LocaleSettings.ps1'
    . '.\tools\build\unattended\Set-PowerSchemeConfiguration.ps1'
    . '.\tools\build\unattended\Set-WindowsSecurityConfiguration.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant BuilderPath ([String]'.\tools\build')

    Set-Variable -Option Constant TestVersion ([String]'TEST_VERSION')
    Set-Variable -Option Constant TestSourcePath ([String]'TEST_SOURCE_PATH')
    Set-Variable -Option Constant TestTemplatesPath ([String]'TEST_TEMPLATES_PATH')
    Set-Variable -Option Constant TestBuildPath ([String]'TEST_BUILD_PATH')
    Set-Variable -Option Constant TestDistPath ([String]'TEST_DIST_PATH')
    Set-Variable -Option Constant TestVmPath ([String]'TEST_VM_PATH')

    Set-Variable -Option Constant LocaleEnglish ([String]'English')
    Set-Variable -Option Constant LocaleRussian ([String]'Russian')

    Set-Variable -Option Constant NonLocalisedFileName ([String]'autounattend.xml')
    Set-Variable -Option Constant TestFileNameRussian ([String]'autounattend-Russian.xml')
    Set-Variable -Option Constant TestFileNameEnglish ([String]'autounattend-English.xml')

    Set-Variable -Option Constant TestConfigsPath ([String]"$TestSourcePath\3-configs")
    Set-Variable -Option Constant TestBaseFilePath ([String]"$TestBuildPath\$NonLocalisedFileName")
    Set-Variable -Option Constant TestVmFilePath ([String]"$TestVmPath\unattend\$NonLocalisedFileName")
    Set-Variable -Option Constant TestBuildFileNameRussian ([String]"$TestBuildPath\$TestFileNameRussian")
    Set-Variable -Option Constant TestBuildFileNameEnglish ([String]"$TestBuildPath\$TestFileNameEnglish")
    Set-Variable -Option Constant TestDistFileNameRussian ([String]"$TestDistPath\$TestFileNameRussian")
    Set-Variable -Option Constant TestDistFileNameEnglish ([String]"$TestDistPath\$TestFileNameEnglish")

    Set-Variable -Option Constant TestSetLocaleSettingsResult ([String]'TEST_SET_LOCALE_SETTINGS_RESULT')
    Set-Variable -Option Constant TestSetAppRemovalListResult ([String]'TEST_SET_APP_REMOVAL_LIST_RESULT')
    Set-Variable -Option Constant TestSetCapabilitiesRemovalListResult ([String]'TEST_SET_CAPABILITIES_REMOVAL_LIST_RESULT')
    Set-Variable -Option Constant TestSetFeaturesRemovalListResult ([String]'TEST_SET_FEATURES_REMOVAL_LIST_RESULT')
    Set-Variable -Option Constant TestSetWindowsSecurityConfigurationResult ([String]'TEST_SET_WINDOWS_SECURITY_CONFIGURATION_RESULT')
    Set-Variable -Option Constant TestSetPowerSchemeConfigurationResult ([String]'TEST_SET_POWER_SCHEME_CONFIGURATION_RESULT')
    Set-Variable -Option Constant TestSetInlineFilesResult ([String]'TEST_SET_INLINE_FILES_RESULT')

    Set-Variable -Option Constant TestTemplateContent ([String]'TEST_TEMPLATE_CONTENT')
    Set-Variable -Option Constant TestBuildFileContent ([String]"      <ImageInstall>
        TEST_BUILD_FILE_CONTENT_1
    </ImageInstall>
    <UserAccounts>
        TEST_BUILD_FILE_CONTENT_2
    </UserAccounts>
    <AutoLogon>
        TEST_BUILD_FILE_CONTENT_3
    </AutoLogon>
    <RunSynchronousCommand wcm:action=`"add`">
        diskpart TEST_BUILD_FILE_CONTENT_4
    </RunSynchronousCommand>
    <File path=`"C:\Windows\Setup\VBoxGuestAdditions.ps1`">
        TEST_BUILD_FILE_CONTENT_5
    </File>
    <File path=`"C:\Windows\Setup\FirstLogon.ps1`">
  {
    &amp; 'C:\Windows\Setup\VBoxGuestAdditions.ps1';
  };
  {
    Set-ItemProperty -LiteralPath 'Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoLogonCount' -Type 'DWord' -Force -Value 0;
  };
    </File>")
    Set-Variable -Option Constant TestDistFileContent ([String]"
    <File path=`"C:\Windows\Setup\FirstLogon.ps1`">
    </File>")
}

Describe 'New-UnattendedFile' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock New-UnattendedBase {}
        Mock Get-Content { return $TestTemplateContent } -ParameterFilter { $Path -eq $TestBaseFilePath }
        Mock Set-LocaleSettings { return $TestSetLocaleSettingsResult }
        Mock Set-AppRemovalList { return $TestSetAppRemovalListResult }
        Mock Set-CapabilitiesRemovalList { return $TestSetCapabilitiesRemovalListResult }
        Mock Set-FeaturesRemovalList { return $TestSetFeaturesRemovalListResult }
        Mock Set-WindowsSecurityConfiguration { return $TestSetWindowsSecurityConfigurationResult }
        Mock Set-PowerSchemeConfiguration { return $TestSetPowerSchemeConfigurationResult }
        Mock Set-InlineFiles { return $TestSetInlineFilesResult }
        Mock Set-Content {} -ParameterFilter { $Path -eq $TestBuildFileNameRussian }
        Mock Set-Content {} -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }
        Mock Copy-Item {}
        Mock Get-Content { return $TestBuildFileContent } -ParameterFilter { $Path -eq $TestBuildFileNameRussian }
        Mock Get-Content { return $TestBuildFileContent } -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }
        Mock Set-Content {} -ParameterFilter { $Path -eq $TestDistFileNameRussian }
        Mock Set-Content {} -ParameterFilter { $Path -eq $TestDistFileNameEnglish }
        Mock Out-Success {}
    }

    It 'Should create unattended files successfully' {
        New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke New-UnattendedBase -Exactly 1 -ParameterFilter {
            $TemplatesPath -eq $TestTemplatesPath -and
            $BaseFile -eq $TestBaseFilePath
        }
        Should -Invoke Get-Content -Exactly 3
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestBaseFilePath -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Set-LocaleSettings -Exactly 2
        Should -Invoke Set-LocaleSettings -Exactly 1 -ParameterFilter {
            $Locale -eq $LocaleEnglish -and
            $TemplateContent -eq $TestTemplateContent
        }
        Should -Invoke Set-LocaleSettings -Exactly 1 -ParameterFilter {
            $Locale -eq $LocaleRussian -and
            $TemplateContent -eq $TestTemplateContent
        }
        Should -Invoke Set-AppRemovalList -Exactly 2
        Should -Invoke Set-AppRemovalList -Exactly 2 -ParameterFilter {
            $ConfigsPath -eq $TestConfigsPath -and
            $TemplateContent -eq $TestSetLocaleSettingsResult
        }
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 2
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 2 -ParameterFilter {
            $ConfigsPath -eq $TestConfigsPath -and
            $TemplateContent -eq $TestSetAppRemovalListResult
        }
        Should -Invoke Set-FeaturesRemovalList -Exactly 2
        Should -Invoke Set-FeaturesRemovalList -Exactly 2 -ParameterFilter {
            $ConfigsPath -eq $TestConfigsPath -and
            $TemplateContent -eq $TestSetCapabilitiesRemovalListResult
        }
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 2
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 2 -ParameterFilter {
            $SourcePath -eq $TestSourcePath -and
            $TemplateContent -eq $TestSetFeaturesRemovalListResult
        }
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 2
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 2 -ParameterFilter {
            $ConfigsPath -eq $TestConfigsPath -and
            $TemplateContent -eq $TestSetWindowsSecurityConfigurationResult
        }
        Should -Invoke Set-InlineFiles -Exactly 2
        Should -Invoke Set-InlineFiles -Exactly 1 -ParameterFilter {
            $Locale -eq $LocaleEnglish -and
            $ConfigsPath -eq $TestConfigsPath -and
            $TemplateContent -eq $TestSetPowerSchemeConfigurationResult
        }
        Should -Invoke Set-InlineFiles -Exactly 1 -ParameterFilter {
            $Locale -eq $LocaleRussian -and
            $ConfigsPath -eq $TestConfigsPath -and
            $TemplateContent -eq $TestSetPowerSchemeConfigurationResult
        }
        Should -Invoke Set-Content -Exactly 4
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestBuildFileNameRussian -and
            $Value -eq $TestSetInlineFilesResult -and
            $NoNewline -eq $True
        }
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestBuildFileNameEnglish -and
            $Value -eq $TestSetInlineFilesResult -and
            $NoNewline -eq $True
        }
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Copy-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestBuildFileNameEnglish -and
            $Destination -eq $TestVmFilePath
        }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestBuildFileNameEnglish -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestBuildFileNameRussian -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestDistFileNameEnglish -and
            $Value -eq $TestDistFileContent -and
            $NoNewline -eq $True
        }
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestDistFileNameRussian -and
            $Value -eq $TestDistFileContent -and
            $NoNewline -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle New-UnattendedBase failure' {
        Mock New-UnattendedBase { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 0
        Should -Invoke Set-LocaleSettings -Exactly 0
        Should -Invoke Set-AppRemovalList -Exactly 0
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 0
        Should -Invoke Set-FeaturesRemovalList -Exactly 0
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-InlineFiles -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Get-Content failure when reading base file' {
        Mock Get-Content { throw $TestException } -ParameterFilter { $Path -eq $TestBaseFilePath }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq $TestBaseFilePath }
        Should -Invoke Set-LocaleSettings -Exactly 0
        Should -Invoke Set-AppRemovalList -Exactly 0
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 0
        Should -Invoke Set-FeaturesRemovalList -Exactly 0
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-InlineFiles -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-LocaleSettings failure' {
        Mock Set-LocaleSettings { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 1
        Should -Invoke Set-AppRemovalList -Exactly 0
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 0
        Should -Invoke Set-FeaturesRemovalList -Exactly 0
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-InlineFiles -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-AppRemovalList failure' {
        Mock Set-AppRemovalList { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 1
        Should -Invoke Set-AppRemovalList -Exactly 1
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 0
        Should -Invoke Set-FeaturesRemovalList -Exactly 0
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-InlineFiles -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-CapabilitiesRemovalList failure' {
        Mock Set-CapabilitiesRemovalList { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 1
        Should -Invoke Set-AppRemovalList -Exactly 1
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 1
        Should -Invoke Set-FeaturesRemovalList -Exactly 0
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-InlineFiles -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-FeaturesRemovalList failure' {
        Mock Set-FeaturesRemovalList { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 1
        Should -Invoke Set-AppRemovalList -Exactly 1
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 1
        Should -Invoke Set-FeaturesRemovalList -Exactly 1
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-InlineFiles -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-WindowsSecurityConfiguration failure' {
        Mock Set-WindowsSecurityConfiguration { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 1
        Should -Invoke Set-AppRemovalList -Exactly 1
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 1
        Should -Invoke Set-FeaturesRemovalList -Exactly 1
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-InlineFiles -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-PowerSchemeConfiguration failure' {
        Mock Set-PowerSchemeConfiguration { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 1
        Should -Invoke Set-AppRemovalList -Exactly 1
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 1
        Should -Invoke Set-FeaturesRemovalList -Exactly 1
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Set-InlineFiles -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-InlineFiles failure' {
        Mock Set-InlineFiles { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 1
        Should -Invoke Set-AppRemovalList -Exactly 1
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 1
        Should -Invoke Set-FeaturesRemovalList -Exactly 1
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Set-InlineFiles -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-Content failure when writing English build file' {
        Mock Set-Content { throw $TestException } -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 1
        Should -Invoke Set-AppRemovalList -Exactly 1
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 1
        Should -Invoke Set-FeaturesRemovalList -Exactly 1
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Set-InlineFiles -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-Content failure when writing Russian build file' {
        Mock Set-Content { throw $TestException } -ParameterFilter { $Path -eq $TestBuildFileNameRussian }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 2
        Should -Invoke Set-AppRemovalList -Exactly 2
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 2
        Should -Invoke Set-FeaturesRemovalList -Exactly 2
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 2
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 2
        Should -Invoke Set-InlineFiles -Exactly 2
        Should -Invoke Set-Content -Exactly 2
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter { $Path -eq $TestBuildFileNameRussian }
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Copy-Item failure' {
        Mock Copy-Item { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 2
        Should -Invoke Set-AppRemovalList -Exactly 2
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 2
        Should -Invoke Set-FeaturesRemovalList -Exactly 2
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 2
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 2
        Should -Invoke Set-InlineFiles -Exactly 2
        Should -Invoke Set-Content -Exactly 2
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Get-Content failure when reading English build file' {
        Mock Get-Content { throw $TestException } -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 2
        Should -Invoke Set-LocaleSettings -Exactly 2
        Should -Invoke Set-AppRemovalList -Exactly 2
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 2
        Should -Invoke Set-FeaturesRemovalList -Exactly 2
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 2
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 2
        Should -Invoke Set-InlineFiles -Exactly 2
        Should -Invoke Set-Content -Exactly 2
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Get-Content failure when reading Russian build file' {
        Mock Get-Content { throw $TestException } -ParameterFilter { $Path -eq $TestBuildFileNameRussian }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 3
        Should -Invoke Set-LocaleSettings -Exactly 2
        Should -Invoke Set-AppRemovalList -Exactly 2
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 2
        Should -Invoke Set-FeaturesRemovalList -Exactly 2
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 2
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 2
        Should -Invoke Set-InlineFiles -Exactly 2
        Should -Invoke Set-Content -Exactly 3
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq $TestBuildFileNameRussian }
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter { $Path -eq $TestDistFileNameEnglish }
        Should -Invoke Set-Content -Exactly 0 -ParameterFilter { $Path -eq $TestDistFileNameRussian }
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-Content failure when writing English dist file' {
        Mock Set-Content { throw $TestException } -ParameterFilter { $Path -eq $TestDistFileNameEnglish }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 2
        Should -Invoke Set-LocaleSettings -Exactly 2
        Should -Invoke Set-AppRemovalList -Exactly 2
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 2
        Should -Invoke Set-FeaturesRemovalList -Exactly 2
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 2
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 2
        Should -Invoke Set-InlineFiles -Exactly 2
        Should -Invoke Set-Content -Exactly 3
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter { $Path -eq $TestDistFileNameEnglish }
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-Content failure when writing Russian dist file' {
        Mock Set-Content { throw $TestException } -ParameterFilter { $Path -eq $TestDistFileNameRussian }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestDistPath $TestVmPath } | Should -Throw

        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Get-Content -Exactly 3
        Should -Invoke Set-LocaleSettings -Exactly 2
        Should -Invoke Set-AppRemovalList -Exactly 2
        Should -Invoke Set-CapabilitiesRemovalList -Exactly 2
        Should -Invoke Set-FeaturesRemovalList -Exactly 2
        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 2
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 2
        Should -Invoke Set-InlineFiles -Exactly 2
        Should -Invoke Set-Content -Exactly 4
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter { $Path -eq $TestDistFileNameRussian }
        Should -Invoke Out-Success -Exactly 0
    }
}
