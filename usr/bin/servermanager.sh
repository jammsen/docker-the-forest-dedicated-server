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

function setupWineInBashRc() {
    echo "Setting up Wine in bashrc"
    mkdir -p /winedata/WINE64
    if [ ! -d /winedata/WINE64/drive_c/windows ]; then
      cd /winedata
      echo "Setting up WineConfig and waiting 15 seconds"
      winecfg > /dev/null 2>&1
      sleep 15
    fi
    cat >> /etc/bash.bashrc <<EOF
export WINEPREFIX=/winedata/WINE64
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
    export WINEPREFIX=/winedata/WINE64
    export WINEARCH=win64
    export DISPLAY=:1.0
    Xvfb :1 -screen 0 1024x768x24 &
    wineboot -r
}

function installServer() {
    # force a fresh install of all
    isWineinBashRcExistent
    steamcmdinstaller.sh
    mkdir -p $SAVEGAME_PATH $CONFIG_PATH
    cp /server.cfg.example $CONFIGFILE_PATH
    sed -i -e "s/###serverSteamAccount###/$SERVER_STEAM_ACCOUNT_TOKEN/g" $CONFIGFILE_PATH
    sed -i -e "s/###RANDOM###/$RANDOM/g" $CONFIGFILE_PATH
    sed -i -e "s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$(hostname -I)/g" $CONFIGFILE_PATH
    bash /steamcmd/steamcmd.sh +runscript /steamcmdinstall.txt
}

function startServer() {
    if ! isVirtualScreenRunning; then
        startVirtualScreenAndRebootWine
    fi
    rm /tmp/.X1-lock 2> /dev/null
    cd /theforest
    wine64 /theforest/TheForestDedicatedServer.exe -batchmode -dedicated -savefolderpath /theforest/saves -configfilepath /theforest/config/config.cfg
}

function startMain() {
    # Check if server is installed, if not try again
    if [ ! -f "/theforest/TheForestDedicatedServer.exe" ]; then
        installServer
    fi
    startServer
}

startMain
