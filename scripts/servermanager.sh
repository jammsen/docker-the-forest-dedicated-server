#!/usr/bin/env bash
# shellcheck disable=SC1091
# IF Bash extension used:
# https://stackoverflow.com/a/13864829
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02

# Uncomment for debugging
#set -x

source /includes/colors.sh
source /includes/config.sh
source /includes/security.sh

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
    mkdir -p "$WINEPREFIX"
    if [ ! -d "$WINEPREFIX"/drive_c/windows ]; then
      # shellcheck disable=SC2164
      cd "$WINEDATA_PATH"
      ei ">>> Setting up WineConfig and waiting 15 seconds"
      winecfg > /dev/null 2>&1
      sleep 15
    fi
}

function startVirtualScreenAndRebootWine() {
    # Start X Window Virtual Framebuffer
    Xvfb :1 -screen 0 1024x768x24 &
    if [[ ${FILTER_SHADER_AND_MESH_AND_WINE_DEBUG} == true ]]; then
        WINEDEBUG=-all wineboot -r
    else
        wineboot -r
    fi
}

function runSteamCmd() {
    local attempt exit_code
    for attempt in 1 2 3; do
        "${STEAMCMD_PATH}"/steamcmd.sh "$@"
        exit_code=$?
        if [[ ${exit_code} -eq 0 ]]; then
            return 0
        fi
        ew ">>> SteamCMD failed (attempt ${attempt}/3) - clearing SteamCMD update state and retrying"
        rm -rf "${STEAMCMD_PATH}/package"
        sleep 5
    done
    ee ">>> SteamCMD failed 3 times in a row - giving up, container will restart"
    exit 1
}

function installServer() {
    # force a fresh install of all
    ei ">>> Doing a fresh install of the gameserver"
    ei "> Setting server-name to jammsen-docker-generated-$RANDOM_NUMBER"

    isWineinBashRcExistent
    mkdir -p "$GAME_SAVEGAME_PATH" "$GAME_CONFIG_PATH"

    # only copy dedicatedserver.cfg if doesn't exist
    #This should be able to be removed, as the server.cfg is now copied from the template
    # if [[ ! -f "$GAME_CONFIGFILE_PATH" ]]; then
        # cp /server.cfg.example "$GAME_CONFIGFILE_PATH"
        # sed -i -e "s/###serverSteamAccount###/$SERVER_STEAM_ACCOUNT_TOKEN/g" "$GAME_CONFIGFILE_PATH"
        # RANDOM_NUMBER=$RANDOM
        # sed -i -e "s/###RANDOM###/$RANDOM_NUMBER/g" "$GAME_CONFIGFILE_PATH"
        # sed -i -e "s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$(hostname -I)/g" "$GAME_CONFIGFILE_PATH"
    # fi

    runSteamCmd +@sSteamCmdForcePlatformType windows +force_install_dir "$GAME_PATH" +login anonymous +app_update 556450 validate +quit
}

function updateServer() {
    # force an update and validation
    ei ">>> Doing an update of the gameserver"
    runSteamCmd +@sSteamCmdForcePlatformType windows +force_install_dir "$GAME_PATH" +login anonymous +app_update 556450 validate +quit
}

function startServer() {
    check_for_default_credentials
    setup_configs
    isWineinBashRcExistent
    if ! isVirtualScreenRunning; then
        startVirtualScreenAndRebootWine
    fi
    ei ">>> Starting the gameserver"
    rm -f /tmp/.X1-lock 2> /dev/null
    # shellcheck disable=SC2164
    cd "$GAME_PATH"

    if [[ ${FILTER_SHADER_AND_MESH_AND_WINE_DEBUG} == true ]]; then
        ei ">>> Shader and Mesh warning/error filtering is enabled"
        # Start the server without output buffering and pipe through grep to filter out shader warnings
        WINEDEBUG=-all stdbuf -oL -eL wine "$GAME_PATH"/TheForestDedicatedServer.exe -batchmode -dedicated -savefolderpath "$GAME_SAVEGAME_PATH" -configfilepath "$GAME_CONFIGFILE_PATH" 2>&1 | \
        stdbuf -oL grep -v -E ".*WARNING: Shader.*|.*ERROR: Shader.*|.*NullReferenceException: Object reference not set to an instance of an object.*|.*at TheForest.Utils.Input.GetAxis.*|.*at UICamera\..*|.*\(Filename:.*|.*Platform assembly:.*|.*Fallback handler could not load library.*|.*JobTempAlloc has allocations.*|.*OnLevelWasLoaded was found on.*|.*This message has been deprecated and will be removed in a later version of Unity.*|.*Add a delegate to SceneManager.sceneLoaded instead.*|^Unloading [0-9]+ .*|^UnloadTime: .*|^Total: .*FindLiveObjects.*|^[[:space:]]*$"
        # Start the server with output buffering and pipe through grep to filter out shader warnings
        # If you want to NOT use stdbuf, comment out the above line and uncomment the next lines and build the image yourself
        #WINEDEBUG=-all wine "$GAME_PATH"/TheForestDedicatedServer.exe -batchmode -dedicated -savefolderpath "$GAME_SAVEGAME_PATH" -configfilepath "$GAME_CONFIGFILE_PATH" 2>&1 | grep -v -E ".*WARNING: Shader.*|.*ERROR: Shader.*|.*NullReferenceException: Object reference not set to an instance of an object.*|.*at TheForest.Utils.Input.GetAxis.*|.*at UICamera\..*|.*\(Filename:.*|.*Platform assembly:.*|.*Fallback handler could not load library.*|.*JobTempAlloc has allocations.*|.*OnLevelWasLoaded was found on.*|.*This message has been deprecated and will be removed in a later version of Unity.*|.*Add a delegate to SceneManager.sceneLoaded instead.*|^Unloading [0-9]+ .*|^UnloadTime: .*|^Total: .*FindLiveObjects.*|^[[:space:]]*$"
    else
        ei ">>> Shader warning filtering is disabled"
        # Start the server without output buffering and without filtering
        stdbuf -oL -eL wine "$GAME_PATH"/TheForestDedicatedServer.exe -batchmode -dedicated -savefolderpath "$GAME_SAVEGAME_PATH" -configfilepath "$GAME_CONFIGFILE_PATH"
        # Start the server with output buffering and without filtering
        # If you want to NOT use stdbuf, comment out the above line and uncomment the next line and build the image yourself
        #wine "$GAME_PATH"/TheForestDedicatedServer.exe -batchmode -dedicated -savefolderpath "$GAME_SAVEGAME_PATH" -configfilepath "$GAME_CONFIGFILE_PATH"
    fi
}

function stopServer() {
    ew ">>> Stopping server..."
	kill -SIGTERM "$(pgrep -f '[Z]:.*TheForestDedicatedServer.exe')"
	tail --pid="$(pgrep -f '[Z]:.*TheForestDedicatedServer.exe')" -f 2>/dev/null
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
    if [ ! -f "/theforest/TheForestDedicatedServer.exe" ]; then
        installServer
    fi
    if [ "${ALWAYS_UPDATE_ON_START}" == "true" ]; then
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
    e "> FILTER_SHADER_AND_MESH_AND_WINE_DEBUG is set to: $FILTER_SHADER_AND_MESH_AND_WINE_DEBUG"

    startMain &
    START_MAIN_PID="$!"

    ew ">>> Server main thread started with pid ${START_MAIN_PID}"
    wait ${START_MAIN_PID}
    exit 0;
done
