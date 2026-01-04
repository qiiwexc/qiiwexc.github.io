@echo off

set /p version=< d/version

git fetch --all --prune
git pull --tags --autostash -r origin master
git add -A -- d
git add -A -- index.html
git commit -m "Release %version%"
git tag -a v%version% -m "Release %version%"
git push origin master:master
git push origin --tags
