function Invoke-OnDispatcher {
    param(
        [Parameter(Position = 0, Mandatory)][Action]$Action,
        [Switch]$FlushRender
    )

    if ($FORM.Dispatcher.CheckAccess()) {
        $Action.Invoke()
        if ($FlushRender) {
            [void]$FORM.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Render, [Action] {})
        }
    } else {
        [void]$FORM.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Render, $Action)
    }
}
