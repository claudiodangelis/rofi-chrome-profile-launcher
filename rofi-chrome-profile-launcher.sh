#!/bin/bash

## If you don't want the script to automatically choose the Chrome version to
## use, set the CHROME_VERSION variable below
CHROME_VERSION=""
CHROME_VERSIONS=(
    "chromium"
    "google-chrome"
    "google-chrome-beta"
    "google-chrome-unstable"
)

if [ -z "$CHROME_VERSION" ]; then
    for version in "${CHROME_VERSIONS[@]}"; do
        if [ -d "$HOME/.config/$version" ]; then
            CHROME_VERSION="$version"
            break
        fi
    done
fi

if [ -z "$CHROME_VERSION" ]; then
    echo "unable to find Chrome version"
    exit 1
fi

CHROME_USER_DATA_DIR="$HOME/.config/$CHROME_VERSION"
if [ ! -d "$CHROME_USER_DATA_DIR" ]; then
    echo "unable to find Chrome user data dir"
    exit 1
fi

DATA=$(python << END
import json
with open("$CHROME_USER_DATA_DIR/Local State") as f:
    data = json.load(f)

# print(data["profile"]["info_cache"])
for profile in data["profile"]["info_cache"]:
    print("%s_____%s" % (profile, data["profile"]["info_cache"][profile]["name"]))
END
)

declare -A profiles=()
while read -r line
do
    PROFILE="${line%_____*}"
    NAME="${line#*_____}"
    # echo "$PROFILE - $NAME"
    profiles["$NAME"]="$PROFILE"
done <<< "$DATA"

if [ -z "$@" ]; then
    for profile in "${!profiles[@]}"; do
        echo $profile
    done
else
    NAME="${@}"
    $CHROME_VERSION --profile-directory="${profiles[$NAME]}" &> /dev/null
fi
