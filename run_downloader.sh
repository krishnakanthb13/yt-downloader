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
        bash youtube_download.sh
    elif [ "$MCHOICE" = "2" ]; then
        clear
        bash youtube_shorts_download.sh
    elif [ "$MCHOICE" = "3" ]; then
        clear
        bash youtube_bulk_download.sh
    elif [ "$MCHOICE" = "4" ]; then
        clear
        echo -e "${GREEN}============================================${NC}"
        echo -e "${GREEN} Updating yt-dlp...${NC}"
        echo -e "${GREEN}============================================${NC}"
        # Try each update method in turn, falling through to the next one
        # if the current method fails (previously the chain stopped at the
        # first *installed* tool even if its command failed).
        UPDATED="no"
        if command -v pipx >/dev/null 2>&1 && pipx list 2>/dev/null | grep -q "yt-dlp"; then
            pipx upgrade yt-dlp && UPDATED="yes"
        fi
        if [ "$UPDATED" = "no" ] && command -v pip3 >/dev/null 2>&1; then
            pip3 install -U "yt-dlp[default]" && UPDATED="yes"
        fi
        if [ "$UPDATED" = "no" ] && command -v pip >/dev/null 2>&1; then
            pip install -U "yt-dlp[default]" && UPDATED="yes"
        fi
        if [ "$UPDATED" = "no" ] && command -v python3 >/dev/null 2>&1; then
            python3 -m pip install -U "yt-dlp[default]" && UPDATED="yes"
        fi
        if [ "$UPDATED" = "no" ] && command -v python >/dev/null 2>&1; then
            python -m pip install -U "yt-dlp[default]" && UPDATED="yes"
        fi
        if [ "$UPDATED" = "no" ]; then
            yt-dlp -U && UPDATED="yes"
        fi
        echo
        if [ "$UPDATED" = "yes" ]; then
            echo "yt-dlp updated successfully."
        else
            echo "Could not update yt-dlp automatically."
            echo "Reinstall it manually if needed (see the README)."
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
