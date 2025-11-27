#!/bin/sh

# This script deploys the built binaries to my server:
# https://tho-otto/snapshots/magicmac

SERVER=web196@server43.webgo24.de
UPLOAD_DIR=$SERVER:/home/www/snapshots

if [ -z "$SSH_ID" ]
then
	echo "error: SSH_ID is undefined" >&2
	exit 1
fi

# variables (some already set in build.sh)
RELEASE_DATE=`date -u +%Y-%m-%dT%H:%M:%S`

echo "Deploying $BINARCHIVE"

cd "$OUT"

eval "$(ssh-agent -s)"

PROJECT_DIR="$PROJECT_LOWER"

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

link_file() {
	local from="$1"
	local to="$2"
	for i in 1 2 3
	do
		ssh -o "StrictHostKeyChecking no" $SERVER -- "cd www/snapshots/${PROJECT_DIR}; ln -sf $from $to"
		[ $? = 0 ] && return 0
		sleep 1
	done
	exit 1
}

#upload file(s):
echo "upload ${BINARCHIVE}"
upload_file "${BINARCHIVE}" "${UPLOAD_DIR}/${PROJECT_LOWER}/${BINARCHIVE}"
link_file "$BINARCHIVE" "${PROJECT_LOWER}-${ATAG}-latest.zip"
echo "upload ${SRCARCHIVE}"
upload_file "${SRCARCHIVE}" "${UPLOAD_DIR}/${PROJECT_LOWER}/${SRCARCHIVE}"
for f in magiconlinux-*; do
	if test -f "$f"; then
		upload_file "$f" "${UPLOAD_DIR}/${PROJECT_LOWER}/$f"
		zip=${f##*-}
		lang=${zip%.zip}
		link_file "$f" "magiconlinux-${lang}-latest.zip"
	fi
done

echo ${PROJECT_LOWER}-${VERSION} > .latest_version
upload_file .latest_version "${UPLOAD_DIR}/${PROJECT_DIR}/.latest_version"

echo ""

# purge old snapshots
