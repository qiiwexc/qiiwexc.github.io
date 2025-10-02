function Initialize-AppDirectory {
    New-Item -Force -ItemType Directory $PATH_APP_DIR | Out-Null
}
