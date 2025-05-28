#!/bin/sh
set -e
readonly PACK_FILE="/opt/pack/pack.toml"

# auxiliary
## log
# shellcheck disable=SC2059
logf() { _FORMAT="$1"; shift; printf "INFO: $_FORMAT\n" "$@" 1>&2; }
# shellcheck disable=SC2059
errorf() { _FORMAT="$1"; shift; printf "ERROR: $_FORMAT\n" "$@" 1>&2; }

logf 'Installing mods'
java -cp /opt/packwiz-installer.jar link.infra.packwiz.installer.DevMainKt \
    --no-gui \
    --side server \
    file://"$PACK_FILE"

_VERSIONS="$(awk -F '[ ="]+' '/[versions]/ && ($1 == "neoforge" || $1 == "minecraft") {print $1"="$2}' "$PACK_FILE")"
_MINECRAFT_VERSION="$(echo "$_VERSIONS" | awk -F '=' '$1 == "minecraft" {print $2}')"
[ -z "$_MINECRAFT_VERSION" ] && (errorf 'Failed to determine MC version"' exit 1)
_NEOFORGE_VERSION="$(echo "$_VERSIONS" | awk -F '=' '$1 == "neoforge" {print $2}')"
[ -z "$_NEOFORGE_VERSION" ] && (errorf 'Failed to determine loader version'; exit 1)
logf 'Loader: NeoForge %s for Minecraft %s' "$_NEOFORGE_VERSION" "$_MINECRAFT_VERSION"

_JVM_ARGS_FILE="libraries/net/neoforged/neoforge/$_NEOFORGE_VERSION/unix_args.txt"
if [ ! -e "$_JVM_ARGS_FILE" ]; then
    logf 'Installing loader'

    _INSTALLER_PATH="$(mktemp)"
    curl -fL \
        -# --proto =http,https -o "$_INSTALLER_PATH" \
        "https://maven.neoforged.net/releases/net/neoforged/neoforge/$_NEOFORGE_VERSION/neoforge-$_NEOFORGE_VERSION-installer.jar"
    java -jar "$_INSTALLER_PATH" \
        --installServer
    rm "$_INSTALLER_PATH" tmp.*.log run.bat run.sh
fi

logf 'Preparing files'
. "/opt/pack/docker/motd.sh"

[ ! -f eula.txt ] && printf 'eula=true\n' > eula.txt
if [ ! -f config/decent-discord-bridge/config.toml ]; then
    mkdir -p config/decent-discord-bridge
    cat <<EOF > config/decent-discord-bridge/config.toml
channel-id = ${DISCORD_CHANNEL_ID:-0}
webhook-id = ${DISCORD_WEBHOOK_ID:-0}
webhook-token = "${DISCORD_WEBHOOK_TOKEN}"
token = "${DISCORD_BOT_TOKEN}"
broadcast-lifecycle-events = true
EOF
fi


logf 'Launching server'
exec java \
    -XX:MaxRAMPercentage=85 \
    "@$_JVM_ARGS_FILE" \
    --nogui
