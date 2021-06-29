#!/bin/sh
# Use as: ". setup_env.sh"

SCRIPT_DIR="$(dirname "$0")"
SCRIPT_DIR=$(cd $SCRIPT_DIR; pwd)
echo "SCRIPT_DIR=$SCRIPT_DIR" >> $GITHUB_ENV

PROJECT_REPO=$(echo "${GITHUB_REPOSITORY}" | cut -d '/' -f 1)
echo "PROJECT_REPO=${PROJECT_REPO}" >> $GITHUB_ENV

PROJECT_NAME=$(echo "${GITHUB_REPOSITORY}" | cut -d '/' -f 2)
echo "PROJECT_NAME=${PROJECT_NAME}" >> $GITHUB_ENV

BRANCH=$(echo "${GITHUB_REF}" | cut -d '/' -f 3)

SHORT_ID=$(echo ${GITHUB_SHA} | cut -c 1-7)
echo "SHORT_ID=$SHORT_ID" >> $GITHUB_ENV

PROJECT_LOWER=`echo ${PROJECT_NAME} | tr '[[:upper:]]' '[[:lower:]]'`
echo "PROJECT_LOWER=${PROJECT_LOWER}" >> $GITHUB_ENV


# GITHUB_HEAD_REF is only set for pull requests
if [ "${GITHUB_HEAD_REF}" = "" ]
then
    COMMIT_MESSAGE="[${PROJECT_NAME}] [${BRANCH}] Commit: https://github.com/${PROJECT_REPO}/${PROJECT_NAME}/commit/${GITHUB_SHA}"
fi

echo "COMMIT_MESSAGE=$COMMIT_MESSAGE" >> $GITHUB_ENV
