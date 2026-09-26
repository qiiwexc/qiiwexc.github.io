BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase

    # Stands in for a command that touches the window
    function Set-TestValue {
        param(
            [Parameter(Position = 0, Mandatory)][String]$Value
        )

        $script:Values.Add($Value)
    }

    # Stands in for the window, on the UI thread or off it; Invoke records each call and runs it as the dispatcher would
    function New-TestForm {
        param(
            [Bool]$OnUiThread
        )

        Set-Variable -Option Constant Form ([PSCustomObject]@{ Dispatcher = [PSCustomObject]@{} })
        $Form.Dispatcher | Add-Member -MemberType ScriptMethod -Name CheckAccess -Value { return $OnUiThread }.GetNewClosure()
        $Form.Dispatcher | Add-Member -MemberType ScriptMethod -Name Invoke -Value {
            param($Priority, $Method, $Argument)
            $script:Dispatched.Add([PSCustomObject]@{ Priority = $Priority; Method = $Method; Argument = $Argument })
            if ($Null -ne $Argument) { $Method.Invoke($Argument) } else { $Method.Invoke() }
        }
        return $Form
    }
}

Describe 'Invoke-OnDispatcher' {
    BeforeEach {
        [Collections.Generic.List[String]]$script:Values = @()
        [Collections.Generic.List[Object]]$script:Dispatched = @()
    }

    It 'Should run the command at once on the UI thread' {
        $FORM = New-TestForm -OnUiThread $True

        Invoke-OnDispatcher 'Set-TestValue' @{ Value = 'DIRECT' }

        $script:Values | Should -BeExactly @('DIRECT')
        $script:Dispatched | Should -HaveCount 0
    }

    It 'Should let the window render after the command on the UI thread when asked to' {
        $FORM = New-TestForm -OnUiThread $True

        Invoke-OnDispatcher 'Set-TestValue' @{ Value = 'FLUSHED' } -FlushRender

        $script:Values | Should -BeExactly @('FLUSHED')
        $script:Dispatched | Should -HaveCount 1
        $script:Dispatched[0].Priority | Should -Be ([Windows.Threading.DispatcherPriority]::Render)
    }

    It 'Should hand only the command and its parameters to the UI thread from another thread' {
        $FORM = New-TestForm -OnUiThread $False

        Invoke-OnDispatcher 'Set-TestValue' @{ Value = 'DISPATCHED' }

        $script:Values | Should -BeExactly @('DISPATCHED')
        $script:Dispatched | Should -HaveCount 1
        $script:Dispatched[0].Priority | Should -Be ([Windows.Threading.DispatcherPriority]::Render)
        [Object]::ReferenceEquals($script:Dispatched[0].Method, $UI_THREAD_COMMAND) | Should -BeTrue
        $script:Dispatched[0].Argument.Command | Should -BeExactly 'Set-TestValue'
        $script:Dispatched[0].Argument.Parameters.Value | Should -BeExactly 'DISPATCHED'
    }

    It 'Should refuse a script block in place of a command name' {
        $FORM = New-TestForm -OnUiThread $False

        { Invoke-OnDispatcher { Set-TestValue 'SCRIPT_BLOCK' } } | Should -Throw

        $script:Values | Should -HaveCount 0
        $script:Dispatched | Should -HaveCount 0
    }
}

Describe 'UI thread dispatch' {
    # A script block the async runspace created, run on the UI thread, waits for that runspace once the operation is
    # being stopped, while the operation waits for the UI thread
    It 'Should be the only code of the app that calls into a dispatcher' {
        Set-Variable -Option Constant SourcePath ([String](Resolve-Path "$PSScriptRoot\..\.."))

        [String[]]$Calls = @(Get-ChildItem $SourcePath -Recurse -Filter *.ps1 | Where-Object { $_.Name -notlike '*.Tests.ps1' -and $_.FullName -ne $PSCommandPath.Replace('.Tests.ps1', '.ps1') } | ForEach-Object {
                [Management.Automation.Language.Parser]::ParseFile($_.FullName, [Ref]$Null, [Ref]$Null).FindAll({
                        $args[0] -is [Management.Automation.Language.InvokeMemberExpressionAst] -and
                        $args[0].Member.Extent.Text -match '^(Begin)?Invoke(Async)?$' -and
                        $args[0].Expression.Extent.Text -match 'Dispatcher$'
                    }, $True) | ForEach-Object { "$($_.Extent.File):$($_.Extent.StartLineNumber)" }
            })

        $Calls | Should -BeNullOrEmpty
    }
}
