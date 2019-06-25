#!/bin/bash

# SteamCMD APPID for the-forest-dedicated-server
STEAMCMD_APPID=242760
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

# TODO - finish autoupdater
#function prepareUpdateServer() {
#    if isServerRunning; then
#        stopServer
#    fi
#    sleep 10
#    updateServer
#}

function performServerUpdate() {
    supervisorctl status theforestUpdate | grep RUNNING > /dev/null
    if [[ $? != 0 ]]; then
        supervisorctl start theforestUpdate
    fi
}

function manageServerUpdate() {
    if [[ $1 == 1 ]]; then
        # force an update/install
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
    echo "run stop server code"
}

function startServer() {
    if isServerRunning; then
        echo ">> INFO: Server is already running, skipping start"
        return
    else
        # supervisor start
        supervisorctl status theforestServer | grep RUNNING > /dev/null
        if [[ $? != 0 ]]; then
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
        sleep 30
    done
}

startMainLoop