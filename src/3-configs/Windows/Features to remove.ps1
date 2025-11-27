Set-Variable -Option Constant CONFIG_FEATURES_TO_REMOVE (
    [Collections.Generic.List[String]]@(
        'MediaPlayback'
        'Microsoft-RemoteDesktopConnection'
        'MicrosoftWindowsPowerShellV2Root'
        'Recall'
    )
)
