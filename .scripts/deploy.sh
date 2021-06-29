#!/bin/sh

# This script deploys the built binaries to my server:
# https://tho-otto/snapshots/magicmac

UPLOAD_DIR=web196@server43.webgo24.de:/home/www/snapshots

if [ -z "$SSH_ID" ]
then
	echo "error: SSH_ID is undefined" >&2
	exit 1
fi

# variables
RELEASE_DATE=`date -u +%Y-%m-%dT%H:%M:%S`

echo "Deploying $BINARCHIVE"

cd "$OUT"

eval "$(ssh-agent -s)"

upload_file() {
	local from="$1"
	local to="$2"
	for i in 1 2 3
	do
		scp -o "StrictHostKeyChecking no" "$from" "$to"
		[ $? = 0 ] && return 0
		sleep 1
	done
	exit 1
}

#upload file(s):
echo "upload ${BINARCHIVE}"
upload_file "${BINARCHIVE}" "${UPLOAD_DIR}/${PROJECT_LOWER}/${BINARCHIVE}"
echo "upload ${SRCARCHIVE}"
upload_file "${SRCARCHIVE}" "${UPLOAD_DIR}/${PROJECT_LOWER}/${SRCARCHIVE}"
echo ""

# purge old snapshots
