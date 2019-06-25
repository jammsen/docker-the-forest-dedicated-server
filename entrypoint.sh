#!/usr/bin/env bash

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

steamcmdinstaller.sh
isWineinBashRcExistent
startVirtualScreenAndRebootWine

# start supervisord
"$@"