#!/usr/bin/env bash

set -ex

git init .
git add .

if [ -f app/.flake8 ] ; then
  cp app/.flake8 .
fi

if [ -f app/.pydocstyle ] ; then
  cp app/.pydocstyle .
fi

pre-commit run -a
