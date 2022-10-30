#!/usr/bin/env bash
set -ex

source repo.cfg

IFS=', ' read -r -a GENERIC_CODE <<< \
  "${GENERIC_COMPONENT:-""}"

IFS=', ' read -r -a PYTHON_CODE <<< \
  "${PYTHON_LIBRARIES:-""} \
  ${PYTHON_STRATAGIES:-""}"

if [[ -z "$1" ]]
  then
    echo "Usage: .util/lint/run_lint.sh <environment> <strategy/library>"
    exit 1
fi

if [[ -z "$2" ]]
  then
    echo "Usage: .util/lint/run_lint.sh <environment> <strategy/library>"
    exit 1
fi

lint_generic_one() {
  $COMPONENT=$1
  docker build --build-arg COMPONENT="$COMPONENT" \
    -t "${PROJECT}"_lint_generic \
    -f .util/lint/generic/Dockerfile .
    if [[ $ENVIRONMENT = "development" ]]
    then
      docker run --rm \
        -e PROJECT="$PROJECT" \
        -v "${PWD}/${COMPONENT}/:/usr/src/app" \
        --mount source=precommit-cache,target=/root/.cache \
        "${PROJECT}"_lint_generic:latest
    elif [[ $ENVIRONMENT = "ci" ]]
    then
      docker run --rm \
        -e PROJECT="$PROJECT" \
        "${PROJECT}"_lint_generic:latest
    else
      echo "${ENVIRONMENT}" not supported
      exit 1
    fi

    if [ -f "$COMPONENT/override.json" ]; then
      LINT=$(cat "$COMPONENT/override.json" | jq -r ".lint")
      if [[ "$LINT" = "python" ]]; then
        lint_python_one "$COMPONENT"
      fi
    fi
}

lint_python_one() {
  COMPONENT=$1
  docker build --build-arg COMPONENT="$COMPONENT" \
    -t "${PROJECT}"_lint_python \
    -f .util/lint/python/Dockerfile .
  if [[ $ENVIRONMENT = "development" ]]
  then
    docker run --rm \
     -e PROJECT="$PROJECT" \
     -v "${PWD}/${COMPONENT}/:/usr/src/app" \
     -v /usr/src/app/.data \
     -v /usr/src/app/target \
     --mount source=precommit-cache,target=/root/.cache \
     "${PROJECT}"_lint_python:latest
  elif [[ $ENVIRONMENT = "ci" ]]
  then
    docker run --rm \
      -e PROJECT="${PROJECT}" \
      "${PROJECT}"_lint_python:latest
  else
    echo "${ENVIRONMENT} not supported"
    exit 1
  fi
}

lint_generic_all() {
  arr=("$@")
  for COMPONENT in "${arr[@]}"
  do
    lint_generic_one "$COMPONENT"
  done
}

lint_python_all() {
  arr=("$@")
  for COMPONENT in "${arr[@]}"
  do
    lint_python_one "$COMPONENT"
  done
}

ENVIRONMENT=$1
COMPONENT=$2

if [[ $COMPONENT = "all" ]]
then
  lint_generic_all "${GENERIC_CODE[@]}"
  lint_generic_all "${PYTHON_CODE[@]}"
  lint_python_all "${PYTHON_CODE[@]}"
else
  lint_generic_one "$COMPONENT"
  # shellcheck disable=SC2076
  if [[ " ${PYTHON_CODE[*]} " =~ " $COMPONENT " ]]; then
    lint_python_one "$COMPONENT"
  fi
fi
