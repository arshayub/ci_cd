#!/bin/bash
function parse_git_dirty() {
    git diff --quiet --ignore-submodules HEAD 2>/dev/null; [ $? -eq 1 ] && echo "*"
}
# checks if branch has something pending
function parse_git_dirty_word() {
    git diff --quiet --ignore-submodules HEAD 2>/dev/null; 
    if [[ $? -eq 1 ]]
    then
      echo "Dirty"
    else
      echo "Nothing to commit"
    fi
}

# gets the current git branch
function parse_git_branch() {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/*\(.*\)/\1$(parse_git_dirty)/"
}

# gets the current git branch
function parse_git_tag() {
    git describe --exact-match --tags HEAD 2> /dev/null
}

# get last commit hash prepended with @ (i.e. @8a323d0)
function parse_git_hash() {
    git rev-parse --short HEAD 2> /dev/null | sed "s/\(.*\)/@\1/"
}

function parse_git_last_commits() {
    git  log --oneline -n 5 2>/dev/null;
}
