# Pester dot-sources this file into every test file before running it, in a parallel worker's runspace
# as well as in the calling session. A worker starts from a fresh runspace, so without it the tests there
# would lose the strict mode and error preference tools\test.ps1 sets, and pass where they should fail

# For discovery: the code of a test file outside its BeforeAll and It blocks
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# For the run: registered ahead of the test file's own BeforeAll, in the scope every block inherits from
BeforeAll {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
}
