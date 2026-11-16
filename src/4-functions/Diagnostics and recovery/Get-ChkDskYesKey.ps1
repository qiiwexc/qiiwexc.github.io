# chkdsk asks before it schedules a scan of a drive in use, and takes for yes only the first letter of Windows' word
# for Yes in the display language: 'J' in German, 'O' in French. It reads the word from the messages of ulib.dll, and
# so does this, answering 'Y' where it cannot
function Get-ChkDskYesKey {
    [String]$Word = ''

    try {
        # As data rather than code, so that Windows looks the messages up in the language pack of the display language
        # (LOAD_LIBRARY_AS_DATAFILE | LOAD_LIBRARY_AS_IMAGE_RESOURCE)
        Set-Variable -Option Constant Library ([IntPtr][Qiiwexc.NativeMethods]::LoadLibraryEx("$PATH_SYSTEM_32\ulib.dll", [IntPtr]::Zero, 0x22))
        if ($Library -ne [IntPtr]::Zero) {
            try {
                [Text.StringBuilder]$Message = [Text.StringBuilder]::new(256)
                # FORMAT_MESSAGE_FROM_HMODULE | FORMAT_MESSAGE_IGNORE_INSERTS. 3022 is the word for Yes, 3023 the one for No
                if ([Qiiwexc.NativeMethods]::FormatMessage(0xA00, $Library, 3022, 0, $Message, $Message.Capacity, [IntPtr]::Zero) -gt 0) {
                    $Word = $Message.ToString().Trim()
                }
            } finally {
                [Void][Qiiwexc.NativeMethods]::FreeLibrary($Library)
            }
        }
    } catch {
        $Word = ''
    }

    # A letter and nothing else, as it goes into a command line
    if ($Word -and [Char]::IsLetter($Word[0])) {
        return $Word.Substring(0, 1)
    }

    Write-LogDebug "Could not read Windows' word for Yes, answering chkdsk with 'Y'"
    return 'Y'
}
