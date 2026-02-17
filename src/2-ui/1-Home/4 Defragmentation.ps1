New-Card 'Defragmentation'


[ScriptBlock]$BUTTON_FUNCTION = { Start-Defragmentation }
New-Button 'Defragment drives' $BUTTON_FUNCTION
