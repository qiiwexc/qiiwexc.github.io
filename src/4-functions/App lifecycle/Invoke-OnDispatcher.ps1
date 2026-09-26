# Runs a command of the app on the UI thread for any other thread. It is created here, so it belongs to the UI
# thread's runspace, and Start-AsyncOperation hands it to the async runspace: a script block that the async
# runspace created must never run on the UI thread. Once that runspace is being stopped, running one waits for
# the runspace, while the operation waits for the UI thread, and the window freezes for good
Set-Variable -Option Constant UI_THREAD_COMMAND ([Action[Hashtable]] {
        param($Call)

        Set-Variable -Option Constant Parameters ([Hashtable]$Call.Parameters)
        & $Call.Command @Parameters
    })

# Runs a command that touches the window on the UI thread, which owns it: at once when already there, otherwise
# through UI_THREAD_COMMAND, so only data crosses to the UI thread
function Invoke-OnDispatcher {
    param(
        [Parameter(Position = 0, Mandatory)][ValidatePattern('^[\w-]+$')][String]$Command,
        [Parameter(Position = 1)][Hashtable]$Parameters = @{},
        [Switch]$FlushRender
    )

    if ($FORM.Dispatcher.CheckAccess()) {
        & $Command @Parameters
        if ($FlushRender) {
            [Void]$FORM.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Render, [Action] {})
        }
    } else {
        [Void]$FORM.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Render, $UI_THREAD_COMMAND, @{ Command = $Command; Parameters = $Parameters })
    }
}
