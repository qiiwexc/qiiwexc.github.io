BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant BuilderPath ([String]'.\tools\build')

    . '.\tools\common\Progressbar.ps1'
    . '.\tools\common\Read-TextFile.ps1'
    . '.\tools\common\Write-TextFile.ps1'
    . "$BuilderPath\unattended\New-UnattendedBase.ps1"
    . "$BuilderPath\unattended\Set-AppRemovalList.ps1"
    . "$BuilderPath\unattended\Set-InlineFiles.ps1"
    . "$BuilderPath\unattended\Set-LocaleSettings.ps1"
    . "$BuilderPath\unattended\Set-MalwareProtectionConfiguration.ps1"
    . "$BuilderPath\unattended\Set-PowerSchemeConfiguration.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestVersion ([Version]'1.2.3')
    Set-Variable -Option Constant TestSourcePath ([String]'TEST_SOURCE_PATH')
    Set-Variable -Option Constant TestTemplatesPath ([String]'TEST_TEMPLATES_PATH')
    Set-Variable -Option Constant TestBuildPath ([String]'TEST_BUILD_PATH')
    Set-Variable -Option Constant TestVmPath ([String]'TEST_VM_PATH')

    Set-Variable -Option Constant LocaleEnglish ([String]'English')
    Set-Variable -Option Constant LocaleRussian ([String]'Russian')

    Set-Variable -Option Constant NonLocalisedFileName ([String]'autounattend.xml')
    Set-Variable -Option Constant TestFileNameRussian ([String]'autounattend-Russian.xml')
    Set-Variable -Option Constant TestFileNameEnglish ([String]'autounattend-English.xml')

    Set-Variable -Option Constant TestConfigsPath ([String]"$TestSourcePath\3-configs")
    Set-Variable -Option Constant TestUnattendedPath ([String]"$BuilderPath\unattended")
    Set-Variable -Option Constant TestBaseFilePath ([String]"$TestBuildPath\$NonLocalisedFileName")
    Set-Variable -Option Constant TestVmFilePath ([String]"$TestVmPath\unattend\$NonLocalisedFileName")
    Set-Variable -Option Constant TestBuildFileNameRussian ([String]"$TestBuildPath\$TestFileNameRussian")
    Set-Variable -Option Constant TestBuildFileNameEnglish ([String]"$TestBuildPath\$TestFileNameEnglish")

    Set-Variable -Option Constant TestSetLocaleSettingsResult ([String]'TEST_SET_LOCALE_SETTINGS_RESULT')
    Set-Variable -Option Constant TestSetAppRemovalListResult ([String]'TEST_SET_APP_REMOVAL_LIST_RESULT')
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
        Mock New-Activity {}
        Mock Write-ActivityProgress {}
        Mock New-UnattendedBase {}
        Mock Read-TextFile { return $TestTemplateContent } -ParameterFilter { $Path -eq $TestBaseFilePath }
        Mock Set-LocaleSettings { return $TestSetLocaleSettingsResult }
        Mock Set-AppRemovalList { return $TestSetAppRemovalListResult }
        Mock Set-MalwareProtectionConfiguration { return $TestSetWindowsSecurityConfigurationResult }
        Mock Set-PowerSchemeConfiguration { return $TestSetPowerSchemeConfigurationResult }
        Mock Set-InlineFiles { return $TestSetInlineFilesResult }
        Mock Write-TextFile {} -ParameterFilter { $Path -eq $TestBuildFileNameRussian }
        Mock Write-TextFile {} -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }
        Mock Copy-Item {}
        Mock Read-TextFile { return $TestBuildFileContent } -ParameterFilter { $Path -eq $TestBuildFileNameRussian }
        Mock Read-TextFile { return $TestBuildFileContent } -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }
        Mock Write-TextFile {} -ParameterFilter { $Path -eq $TestBuildFileNameRussian }
        Mock Write-TextFile {} -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }
        Mock Write-ActivityCompleted {}
    }

    It 'Should create unattended files' {
        New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestVmPath

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 18
        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke New-UnattendedBase -Exactly 1 -ParameterFilter {
            $TemplatesPath -eq $TestTemplatesPath -and
            $BaseFile -eq $TestBaseFilePath
        }
        Should -Invoke Read-TextFile -Exactly 3
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestBaseFilePath }
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
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 2
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 2 -ParameterFilter {
            $SourcePath -eq $TestSourcePath -and
            $TemplateContent -eq $TestSetAppRemovalListResult
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
            $UnattendedPath -eq $TestUnattendedPath -and
            $TemplateContent -eq $TestSetPowerSchemeConfigurationResult
        }
        Should -Invoke Set-InlineFiles -Exactly 1 -ParameterFilter {
            $Locale -eq $LocaleRussian -and
            $ConfigsPath -eq $TestConfigsPath -and
            $UnattendedPath -eq $TestUnattendedPath -and
            $TemplateContent -eq $TestSetPowerSchemeConfigurationResult
        }
        Should -Invoke Write-TextFile -Exactly 4
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestBuildFileNameRussian -and
            $Content -eq $TestSetInlineFilesResult -and
            $NoNewline -eq $True
        }
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestBuildFileNameEnglish -and
            $Content -eq $TestSetInlineFilesResult -and
            $NoNewline -eq $True
        }
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Copy-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestBuildFileNameEnglish -and
            $Destination -eq $TestVmFilePath
        }
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestBuildFileNameRussian }
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestBuildFileNameEnglish -and
            $Content -eq $TestDistFileContent -and
            $NoNewline -eq $True
        }
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestBuildFileNameRussian -and
            $Content -eq $TestDistFileContent -and
            $NoNewline -eq $True
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should skip copying to VM path in CI mode' {
        New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestVmPath -CI

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 18
        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Read-TextFile -Exactly 3
        Should -Invoke Set-LocaleSettings -Exactly 2
        Should -Invoke Set-AppRemovalList -Exactly 2
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 2
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 2
        Should -Invoke Set-InlineFiles -Exactly 2
        Should -Invoke Write-TextFile -Exactly 4
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle New-UnattendedBase failure' {
        Mock New-UnattendedBase { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 2
        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Read-TextFile -Exactly 0
        Should -Invoke Set-LocaleSettings -Exactly 0
        Should -Invoke Set-AppRemovalList -Exactly 0
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-InlineFiles -Exactly 0
        Should -Invoke Write-TextFile -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Read-TextFile failure when reading base file' {
        Mock Read-TextFile { throw $TestException } -ParameterFilter { $Path -eq $TestBaseFilePath }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 3
        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestBaseFilePath }
        Should -Invoke Set-LocaleSettings -Exactly 0
        Should -Invoke Set-AppRemovalList -Exactly 0
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-InlineFiles -Exactly 0
        Should -Invoke Write-TextFile -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-LocaleSettings failure' {
        Mock Set-LocaleSettings { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 1
        Should -Invoke Set-AppRemovalList -Exactly 0
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-InlineFiles -Exactly 0
        Should -Invoke Write-TextFile -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-AppRemovalList failure' {
        Mock Set-AppRemovalList { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 1
        Should -Invoke Set-AppRemovalList -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 0
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-InlineFiles -Exactly 0
        Should -Invoke Write-TextFile -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-MalwareProtectionConfiguration failure' {
        Mock Set-MalwareProtectionConfiguration { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 6
        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 1
        Should -Invoke Set-AppRemovalList -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Set-InlineFiles -Exactly 0
        Should -Invoke Write-TextFile -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-PowerSchemeConfiguration failure' {
        Mock Set-PowerSchemeConfiguration { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 7
        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 1
        Should -Invoke Set-AppRemovalList -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Set-InlineFiles -Exactly 0
        Should -Invoke Write-TextFile -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Set-InlineFiles failure' {
        Mock Set-InlineFiles { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 8
        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 1
        Should -Invoke Set-AppRemovalList -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Set-InlineFiles -Exactly 1
        Should -Invoke Write-TextFile -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Write-TextFile failure when writing English build file' {
        Mock Write-TextFile { throw $TestException } -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 9
        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 1
        Should -Invoke Set-AppRemovalList -Exactly 1
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Set-InlineFiles -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Write-TextFile failure when writing Russian build file' {
        Mock Write-TextFile { throw $TestException } -ParameterFilter { $Path -eq $TestBuildFileNameRussian }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 15
        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 2
        Should -Invoke Set-AppRemovalList -Exactly 2
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 2
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 2
        Should -Invoke Set-InlineFiles -Exactly 2
        Should -Invoke Write-TextFile -Exactly 2
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestBuildFileNameRussian }
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Copy-Item failure' {
        Mock Copy-Item { throw $TestException }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 17
        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Set-LocaleSettings -Exactly 2
        Should -Invoke Set-AppRemovalList -Exactly 2
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 2
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 2
        Should -Invoke Set-InlineFiles -Exactly 2
        Should -Invoke Write-TextFile -Exactly 2
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Read-TextFile failure when reading English build file' {
        Mock Read-TextFile { throw $TestException } -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 18
        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Read-TextFile -Exactly 2
        Should -Invoke Set-LocaleSettings -Exactly 2
        Should -Invoke Set-AppRemovalList -Exactly 2
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 2
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 2
        Should -Invoke Set-InlineFiles -Exactly 2
        Should -Invoke Write-TextFile -Exactly 2
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Read-TextFile failure when reading Russian build file' {
        Mock Read-TextFile { throw $TestException } -ParameterFilter { $Path -eq $TestBuildFileNameRussian }

        { New-UnattendedFile $TestVersion $BuilderPath $TestSourcePath $TestTemplatesPath $TestBuildPath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 18
        Should -Invoke New-UnattendedBase -Exactly 1
        Should -Invoke Read-TextFile -Exactly 3
        Should -Invoke Set-LocaleSettings -Exactly 2
        Should -Invoke Set-AppRemovalList -Exactly 2
        Should -Invoke Set-MalwareProtectionConfiguration -Exactly 2
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 2
        Should -Invoke Set-InlineFiles -Exactly 2
        Should -Invoke Write-TextFile -Exactly 3
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestBuildFileNameRussian }
        Should -Invoke Write-TextFile -Exactly 2 -ParameterFilter { $Path -eq $TestBuildFileNameEnglish }
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestBuildFileNameRussian }
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
