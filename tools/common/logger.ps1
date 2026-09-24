# The build and the tests log through the app's own logger, so the two cannot drift apart.
# Only the sink it writes to is replaced: the build has no window, and the console is all there is
. "$PSScriptRoot\..\..\src\4-functions\Common\types.ps1"
. "$PSScriptRoot\..\..\src\4-functions\App lifecycle\Logger.ps1"

function Write-FormLog {}
