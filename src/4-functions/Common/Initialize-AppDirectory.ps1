function Initialize-AppDirectory {
    $Null = New-Item -Force -ItemType Directory $PATH_APP_DIR -ErrorAction Stop
}
