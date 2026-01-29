enum DevLogLevel {
    ERROR
    WARN
    INFO
}

class Config {
    [ValidateNotNullOrEmpty()][String]$key
    [ValidateNotNullOrEmpty()][String]$value
}

class Dependency: PSObject {
    [ValidateNotNullOrEmpty()][String]$name
    [ValidateNotNullOrEmpty()][String]$version
    [ValidateNotNullOrEmpty()][String][ValidateSet('File', 'GitHub', 'GitLab', 'URL')]$source
}

class GitTag: PSObject {
    [ValidateNotNullOrEmpty()][String]$name
}

class GitCommit: PSObject {
    [ValidateNotNullOrEmpty()][String]$sha
}
