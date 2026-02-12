enum DevLogLevel {
    ERROR
    WARN
    INFO
}

class Dependency: PSObject {
    [ValidateNotNullOrEmpty()][String]$name
    [ValidateNotNullOrEmpty()][String]$version
    [ValidateNotNullOrEmpty()][String][ValidateSet('File', 'GitHub', 'GitLab', 'URL')]$source
}

class GitTag: PSObject {
    [ValidateNotNullOrEmpty()][String]$name
}

class GitRelease: PSObject {
    [ValidateNotNullOrEmpty()][String]$tag_name
}

class GitCommit: PSObject {
    [ValidateNotNullOrEmpty()][String]$sha
}
