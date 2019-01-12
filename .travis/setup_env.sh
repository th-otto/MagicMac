#!/bin/sh
# Use as: ". setup_env.sh"

export GITHUB_USER=$(echo "${TRAVIS_REPO_SLUG}" | cut -d '/' -f 1)
export BASE_RAW_URL="https://raw.githubusercontent.com/${GITHUB_USER}"
export PROJECT=$(echo "${TRAVIS_REPO_SLUG}" | cut -d '/' -f 2)
export SHORT_ID=$(git log -n1 --format="%h")
export PROJECT_LOWER=`echo ${PROJECT} | tr '[[:upper:]]' '[[:lower:]]'`

