function Initialize-AppDirectory {
    New-Item -Force -ItemType Directory $PATH_APP_DIR -ErrorAction Stop | Out-Null
}
