#Requires -PSEdition Desktop
#Requires -Version 3

using assembly System.Windows.Forms
using assembly System.IO.Compression.FileSystem

param(
    [String][Parameter(Position = 0)]$CallerPath,
    [Switch]$HideConsole
)
