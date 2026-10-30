# git

    git status                         # what changed
    git diff                           # the changes, not yet staged
    git add file && git commit -m "Filter reads below Q20 (reviewer 2)"
    git log --oneline --graph          # history
    git restore file                   # undo uncommitted changes to a file
    git restore --staged file          # unstage
    git commit --amend                 # fix the last commit (before pushing)
    git switch -c try-salmon           # a branch for an experiment
    git switch main && git merge try-salmon
    git stash / git stash pop          # put changes aside, and back
    git tag v1.0-submitted && git push --tags   # the version behind a paper
    git push / git pull

## Starting, sharing
    git init                           # dvt bio does this for you if needed
    gh repo create NAME --private --source . --push   # on GitHub, from here
    git clone URL

## Never commit
Data (`data/`, big files), results, passwords and tokens. `.gitignore` keeps them out;
check with `git status` before `git add .`.
