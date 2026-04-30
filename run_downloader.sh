#!/bin/bash

# Change to script directory
cd "$(dirname "$0")" || exit

# ANSI Colors
GREEN='\033[0;32m'
NC='\033[0m' # No Color

while true; do
    clear
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}        YOUTUBE DOWNLOADER SUITE${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo
    echo "Choose a downloader option:"
    echo "  1. Single Video Downloader"
    echo "  2. YouTube Shorts Downloader"
    echo "  3. Bulk Downloader (Playlists/Channels)"
    echo "  4. Update yt-dlp"
    echo "  0. Exit"
    echo
    read -rp "Enter choice (0-4): " MCHOICE

    if [ "$MCHOICE" = "1" ]; then
        clear
        ./youtube_download.sh
    elif [ "$MCHOICE" = "2" ]; then
        clear
        ./youtube_shorts_download.sh
    elif [ "$MCHOICE" = "3" ]; then
        clear
        ./youtube_bulk_download.sh
    elif [ "$MCHOICE" = "4" ]; then
        clear
        echo -e "${GREEN}============================================${NC}"
        echo -e "${GREEN} Updating yt-dlp...${NC}"
        echo -e "${GREEN}============================================${NC}"
        if ! python3 -m pip install -U "yt-dlp[default]"; then
            echo -e "\n${GREEN}Standard install failed. Retrying with --user flag...${NC}"
            if ! python3 -m pip install -U --user "yt-dlp[default]"; then
                ERR_CODE=$?
                echo -e "\nERROR: yt-dlp update failed with exit code ${ERR_CODE}." >&2
                echo "Please check your permissions, or try using a virtualenv or running with sudo (if appropriate)." >&2
            fi
        fi
        echo
        read -n 1 -s -r -p "Press any key to continue..."
    elif [ "$MCHOICE" = "0" ]; then
        exit 0
    else
        echo "Invalid choice. Press any key to try again."
        read -n 1 -s -r -p ""
    fi
done
