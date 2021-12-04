#!/bin/sh

NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'

# Function to create default configuration depending on path
create_default_config()
{
    echo "${YELLOW}Could not find an existing dewrito_prefs.cfg. Using default.${NC}"
    echo "${YELLOW}Make sure to adjust important settings like your RCon password!${NC}"

    sleep 5

    echo "Copying default dewrito_prefs.cfg."
    cp ./defaults/dewrito_prefs.cfg .

    echo "Copying default veto/voting json."

    cp ./defaults/veto.json ./config
    cp ./defaults/voting.json ./config
}

# Search for eldorado.exe in game directory
if [ ! -f "eldorado.exe" ]; then
    echo "${RED}Could not find eldorado.exe.${NC}"

    sleep 2
    exit 1
fi

if [ ! -f "dewrito_prefs.cfg" ]; then
    create_default_config
fi

# Xvfb needs cleaning because it doesn't exit cleanly
echo "Cleaning up"
rm /tmp/.X1-lock

echo "Starting virtual frame buffer"
Xvfb :1 -screen 0 320x240x24 &

echo "${GREEN}Starting dedicated server${NC}"

# DLL overrides for Wine are required to prevent issues with master server announcement
export WINEDLLOVERRIDES="winhttp,rasapi32=n"

if [ ! -z "${WINE_DEBUG}" ]; then
    echo "Setting wine to verbose output"
    export WINEDEBUG=warn+all
fi

wine eldorado.exe -launcher -dedicated -window -height 200 -width 200 -minimized

if [ -z "${WAIT_ON_EXIT}" ]; then
    echo "${RED}Server terminated, exiting${NC}"
else
    echo "${RED}Server terminated, waiting${NC}"
    sleep infinity
fi
