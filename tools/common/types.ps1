enum DevLogLevel {
    ERROR
    WARN
    INFO
}

class Config {
    [String]$key
    [String]$value
}

class Dependency: PSObject {
    [String]$name
    [String]$version
    [String][ValidateSet('File', 'GitHub', 'GitLab', 'URL')]$source
}

class GitTag: PSObject {
    [String]$name
}

class GitCommit: PSObject {
    [String]$sha
}
