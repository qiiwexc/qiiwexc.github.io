# The build reports progress through the app's own progress bar, so the two cannot drift apart.
# Only what it drives in the window is replaced: the build has no window, just Write-Progress
. "$PSScriptRoot\..\..\src\4-functions\Common\types.ps1"
. "$PSScriptRoot\..\..\src\4-functions\App lifecycle\Progressbar.ps1"

function Set-Icon {}

function Invoke-OnDispatcher {}
