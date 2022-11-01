#!/usr/bin/env bash

set -ex

git init .
git add .

pre-commit run -a

gitleaks --path=. --config-path=.gitleaks.toml -v --no-git

echo "Successful generic lint"
