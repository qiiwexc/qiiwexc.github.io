function Write-WorkflowAnnotation {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Message,
        [ValidateSet('warning', 'error')][String]$Level = 'warning'
    )

    # A workflow command ends at the first line break: written as it is, a message would show only its first
    # line, and the rest of it could start a command of its own. '%' goes first, so the codes stay codes
    Set-Variable -Option Constant Escaped ([String]$Message.Replace('%', '%25').Replace("`r", '%0D').Replace("`n", '%0A'))

    Write-Host ('::{0}::{1}' -f $Level, $Escaped)
}
