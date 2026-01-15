Set-Variable -Option Constant CONFIG_CAPABILITIES_TO_REMOVE (
    [Collections.Generic.List[String]]@(
        'App.StepsRecorder'
        'App.Support.QuickAssist'
        'Language.TextToSpeech'
    )
)
