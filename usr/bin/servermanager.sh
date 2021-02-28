#!/bin/bash

# SteamCMD APPID for the-forest-dedicated-server
SAVEGAME_PATH="/theforest/saves/"
CONFIG_PATH="/theforest/config/"
CONFIGFILE_PATH="/theforest/config/config.cfg"

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

# TODO - finish autoupdater
#function prepareUpdateServer() {
#    if isServerRunning; then
#        stopServer
#    fi
#    sleep 10
#    updateServer
#}

function setupWineInBashRc() {
    echo "Setting up Wine in bashrc"
    cat >> /etc/bash.bashrc <<EOF
export WINEARCH=win64
export DISPLAY=:1.0
EOF
}

function isWineinBashRcExistent() {
    grep "wine" /etc/bash.bashrc > /dev/null
    if [[ $? -ne 0 ]]; then
        echo "Checking if Wine is set in bashrc"
        setupWineInBashRc
    fi
}

function startVirtualScreenAndRebootWine() {
    # Start X Window Virtual Framebuffer
    export WINEARCH=win64
    export DISPLAY=:1.0
    Xvfb :1 -screen 0 1024x768x24 &
    wineboot -r
}

function performServerUpdate() {
    supervisorctl status theforestUpdate | grep RUNNING > /dev/null
    if [[ $? != 0 ]]; then
        supervisorctl start theforestUpdate
    fi
}

function manageServerUpdate() {
    if [[ $1 == 1 ]]; then
        # force a fresh install of all
        isWineinBashRcExistent
        steamcmdinstaller.sh
        mkdir -p $SAVEGAME_PATH $CONFIG_PATH
        cp /server.cfg.example $CONFIGFILE_PATH
        sed -i -e "s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$(hostname -I)/g" $CONFIGFILE_PATH
        performServerUpdate
    else
        stopServer
        sleep 60
        performServerUpdate
    fi

    # wait for update to be finished
    while $(supervisorctl status theforestUpdate | grep RUNNING > /dev/null); do
        sleep 1
    done

    startServer
}

function stopServer() {
    # supervisor stop
    supervisorctl stop theforestUpdate
}

function startServer() {
    if ! isVirtualScreenRunning; then
        startVirtualScreenAndRebootWine
    fi

    if isServerRunning; then
        echo ">> INFO: Server running, skipping start"
        return
    else
        # supervisor start
        supervisorctl status theforestServer | grep RUNNING > /dev/null
        if [[ $? != 0 ]]; then
            rm /tmp/.X1-lock
            supervisorctl start theforestServer
        fi
    fi
}

function startMainLoop() {
    while true; do
        # Check if server is installed, if not try again
        if [ ! -f "/theforest/TheForestDedicatedServer.exe" ]; then
            manageServerUpdate 1
        fi

        startServer
        sleep 900
    done
}

startMainLoop