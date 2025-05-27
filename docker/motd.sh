#!/bin/sh
set -e
readonly GIT_FOLDER="/opt/pack/.git"

_read_dev_info() {
    _GIT_BRANCH="$(awk '/ref: refs\/heads\// {print substr($0, 17)}' "$GIT_FOLDER"/HEAD)"
    [ -z "$_GIT_BRANCH" ] && return 1

    read -r _GIT_COMMIT <<EOF
$(head -c8 "$GIT_FOLDER/refs/heads/$_GIT_BRANCH")
EOF
    [ -z "$_GIT_COMMIT" ] && return 1
    return 0
}

_read_release_info() {
    _PACKWIZ_VERSION="$(awk -F '[ ="]+' '$1 == "version" {print $2}' "$PACK_FILE")"
}

PACK_VERSION=""
if _read_dev_info; then
    logf 'Git branch: %s; Git commit: %s' "$_GIT_BRANCH" "$_GIT_COMMIT"
    PACK_VERSION="$_GIT_BRANCH@$_GIT_COMMIT"
else _read_release_info
    logf 'Pack version: %s' "$_PACKWIZ_VERSION"
    PACK_VERSION="$_PACKWIZ_VERSION"
fi

export PACK_VERSION
