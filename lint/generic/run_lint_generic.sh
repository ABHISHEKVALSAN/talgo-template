#!/usr/bin/env bash

set -ex

git init .
git add .

pre-commit run -a

gitleaks --path=. --config-path=.gitleaks.toml -v --no-git

# find . --name 'README.md' -execdir gh-md-toc --no-backup {} \;
