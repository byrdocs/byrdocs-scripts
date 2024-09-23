#!/bin/zsh-5.9
usage() {
	cat <<EOF
Usage: $0

Run it at the beginning of organize.sh in order to ensure that no other people are currently organizing files.
EOF
}
CONFIG_FILE="./.config.conf"
if [[ -f "${CONFIG_FILE}" ]]; then
	source "${CONFIG_FILE}"
else
	echo "Configuration file ${CONFIG_FILE} not found!"
	exit 1
fi
cd "${ARCHIVE_DIR}"
git fetch origin master
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base @ @{u})
if [[ "${LOCAL}" != "${REMOTE}" ]] && [[ "${LOCAL}" == "${BASE}" ]]; then
	git pull origin -q master
fi
archive_time=$(git log -1 --format=%ct)
cd "${LOCK_DIR}"
git fetch -q origin master
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base @ @{u})
if [[ "${LOCAL}" != "${REMOTE}" ]] && [[ "${LOCAL}" == "${BASE}" ]]; then
	git pull origin -q master
fi
lock_time=$(git log -1 --format=%ct)
lock_usr=$(git log -1 --format=%an)
if [[ "${archive_time}" -lt "${lock_time}" ]]; then
	if [[ "$(git log -1 --format=%an)" == "$(git config user.name)" ]]; then
		cd "${STOCKPILE_DIR}"
		exit 0
	else
		cd "${STOCKPILE_DIR}"
		echo "Error: it seems that $(git log -1 --format=%an) is currently organizing files. Please wait him/her to finish the task."
		exit 2
	fi
else
	date +%s >| TIMESTAMP
	git add TIMESTAMP
	git commit -m "updated TIMESTAMP"
	git push origin master
fi
cd "${STOCKPILE_DIR}"
exit 0
