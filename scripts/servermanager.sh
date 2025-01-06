#!/usr/bin/env bash
# shellcheck disable=SC1091
# IF Bash extension used:
# https://stackoverflow.com/a/13864829
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02

# Uncomment for debugging
#set -x

source /includes/colors.sh

START_MAIN_PID=

function isServerRunning() {
    if ps axg | grep -F "TheForestDedicatedServer.exe" | grep -v -F 'grep' > /dev/null; then
        true
    else
        false
    fi
}

function isVirtualScreenRunning() {
    if ps axg | grep -F "Xvfb :1 -screen 0 1024x768x24" | grep -v -F 'grep' > /dev/null; then
        true
    else
        false
    fi
}

function isWineinBashRcExistent() {
    grep "wine" /etc/bash.bashrc > /dev/null
    if [[ $? -ne 0 ]]; then
        ei ">>> Checking if Wine is set in bashrc"
        setupWineInBashRc
    fi
}

function setupWineInBashRc() {
    ei ">>> Setting up Wine in bashrc"
    mkdir -p /winedata/WINE64
    if [ ! -d /winedata/WINE64/drive_c/windows ]; then
      # shellcheck disable=SC2164
      cd /winedata
      ei ">>> Setting up WineConfig and waiting 15 seconds"
      winecfg > /dev/null 2>&1
      sleep 15
    fi
}

function startVirtualScreenAndRebootWine() {
    # Start X Window Virtual Framebuffer
    Xvfb :1 -screen 0 1024x768x24 &
    wineboot -r
}

function installServer() {
    RANDOM_NUMBER=$RANDOM
    # force a fresh install of all
    ei ">>> Doing a fresh install of the gameserver"
    ei "> Setting server-name to jammsen-docker-generated-$RANDOM_NUMBER"

    isWineinBashRcExistent
    mkdir -p "$GAME_SAVEGAME_PATH" "$GAME_CONFIG_PATH"

    # only copy dedicatedserver.cfg if doesn't exist
    if [[ ! -f "$GAME_CONFIGFILE_PATH" ]]; then
        cp /server.cfg.example "$GAME_CONFIGFILE_PATH"
        sed -i -e "s/###serverSteamAccount###/$SERVER_STEAM_ACCOUNT_TOKEN/g" "$GAME_CONFIGFILE_PATH"
        sed -i -e "s/###RANDOM###/$RANDOM_NUMBER/g" "$GAME_CONFIGFILE_PATH"
        sed -i -e "s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$(hostname -I)/g" "$GAME_CONFIGFILE_PATH"
    fi

    "${STEAMCMD_PATH}"/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir "$GAME_PATH" +login anonymous +app_update 556450 validate +quit
}

function updateServer() {
    # force an update and validation
    ei ">>> Doing an update of the gameserver"
    "${STEAMCMD_PATH}"/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir "$GAME_PATH" +login anonymous +app_update 556450 validate +quit
}

function startServer() {
    isWineinBashRcExistent
    if ! isVirtualScreenRunning; then
        startVirtualScreenAndRebootWine
    fi
    ei ">>> Starting the gameserver"
    rm -f /tmp/.X1-lock 2> /dev/null
    # shellcheck disable=SC2164
    cd "$GAME_PATH"
    wine64 "$GAME_PATH"/TheForestDedicatedServer.exe -batchmode -dedicated -savefolderpath "$GAME_SAVEGAME_PATH" -configfilepath "$GAME_CONFIGFILE_PATH"
}

function stopServer() {
    ew ">>> Stopping server..."
	kill -SIGTERM "$(pidof TheForestDedicatedServer.exe)"
	tail --pid="$(pidof TheForestDedicatedServer.exe)" -f 2>/dev/null
    ew ">>> Server stopped gracefully"
    exit 143;
}

# Handler for SIGTERM from docker-based stop events
function term_handler() {
    stopServer
}

# Main process thread
function startMain() {
    # Check if server is installed, if not try again
    if [[ ! -f "/theforest/TheForestDedicatedServer.exe" ]]; then
        installServer
    fi
    if [[ ${ALWAYS_UPDATE_ON_START} == true ]]; then
        updateServer
    fi
    startServer
}

# Bash-Trap for exit signals to handle
trap 'kill ${!}; term_handler' SIGTERM

# Main process loop
while true
do
    current_date=$(date +%Y-%m-%d)
    current_time=$(date +%H:%M:%S)
    ei ">>> Starting server manager"
    e "> Started at: $current_date $current_time"
    ei ">>> Listing config options ..."
    e "> ALWAYS_UPDATE_ON_START is set to: $ALWAYS_UPDATE_ON_START"
    e "> SERVER_STEAM_ACCOUNT_TOKEN is set to: $SERVER_STEAM_ACCOUNT_TOKEN"

    startMain &
    START_MAIN_PID="$!"

    ei ">>> Server main thread started with pid ${START_MAIN_PID}"
    wait ${START_MAIN_PID}
    exit 0;
done
