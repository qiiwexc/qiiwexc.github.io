BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase
}

Describe 'Invoke-OnDispatcher' {
    It 'Should invoke action directly when on dispatcher thread' {
        $FORM = [PSCustomObject]@{ Value = $Null }
        $FORM | Add-Member -MemberType NoteProperty -Name Dispatcher -Value ([PSCustomObject]@{})
        $FORM.Dispatcher | Add-Member -MemberType ScriptMethod -Name CheckAccess -Value { return $True }

        $TestAction = [Action] { $FORM.Value = 'INVOKED' }

        Invoke-OnDispatcher $TestAction

        $FORM.Value | Should -BeExactly 'INVOKED'
    }

    It 'Should invoke action via Dispatcher.Invoke when off dispatcher thread' {
        $script:InvokeCalledWith = $Null

        $FORM = [PSCustomObject]@{ Value = $Null }
        $FORM | Add-Member -MemberType NoteProperty -Name Dispatcher -Value ([PSCustomObject]@{})
        $FORM.Dispatcher | Add-Member -MemberType ScriptMethod -Name CheckAccess -Value { return $False }
        $FORM.Dispatcher | Add-Member -MemberType ScriptMethod -Name Invoke -Value {
            param($Priority, $Action)
            $Action.Invoke()
        }

        $TestAction = [Action] { $FORM.Value = 'DISPATCHED' }

        Invoke-OnDispatcher $TestAction

        $FORM.Value | Should -BeExactly 'DISPATCHED'
    }

    It 'Should flush render when FlushRender switch is set on dispatcher thread' {
        $script:FlushCalled = $False

        $FORM = [PSCustomObject]@{ Value = $Null }
        $FORM | Add-Member -MemberType NoteProperty -Name Dispatcher -Value ([PSCustomObject]@{})
        $FORM.Dispatcher | Add-Member -MemberType ScriptMethod -Name CheckAccess -Value { return $True }
        $FORM.Dispatcher | Add-Member -MemberType ScriptMethod -Name Invoke -Value {
            param($Priority, $Action)
            $script:FlushCalled = $True
            $Action.Invoke()
        }

        $TestAction = [Action] { $FORM.Value = 'FLUSHED' }

        Invoke-OnDispatcher $TestAction -FlushRender

        $FORM.Value | Should -BeExactly 'FLUSHED'
        $script:FlushCalled | Should -BeTrue
    }
}
