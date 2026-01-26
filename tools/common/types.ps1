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

class GitDependency: Dependency {
    [String][ValidateSet('GitHub', 'GitLab')]$source
    [String]$repository
    [String][ValidateSet('compare', 'tags', 'commits')]$mode
}

class GitLabDependency: GitDependency {
    [String][ValidateSet('GitLab')]$source
    [String]$projectId
}

class GitHubDependency: GitDependency {
    [String][ValidateSet('GitHub')]$source
}

class WebDependency: Dependency {
    [String][ValidateSet('URL')]$source
    [String]$url
    [String]$regex
}

class FileDependency: Dependency {
    [String][ValidateSet('File')]$source
}

class GitTag: PSObject {
    [String]$name
}

class GitCommit: PSObject {
    [String]$sha
}
