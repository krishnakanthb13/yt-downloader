#!/bin/bash
set -euo pipefail
trap 'echo; echo "Cancelled."; exit 130' INT

# Change to script directory
cd "$(dirname "$0")" || exit

# ANSI Colors
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check that yt-dlp exists
if ! command -v yt-dlp >/dev/null 2>&1; then
    echo -e "${YELLOW}ERROR: yt-dlp is not installed.${NC}"
    echo "Run option 4 from the main menu first."
    exit 1
fi


# Detect internet connection
if ! command -v curl >/dev/null 2>&1 || ! curl --connect-timeout 5 -A "Mozilla/5.0" -Is https://www.youtube.com >/dev/null 2>&1; then
    echo -e "${YELLOW}WARNING: Could not connect to youtube.com. You may be offline.${NC}"
fi

# ============================================
# HARDCODE YOUR SAVE LOCATION HERE
# Example: SAVE_DIR="$HOME/YouTube Shorts"
# Leave blank to be asked every time
# ============================================
SAVE_DIR=""

# ============================================

echo -e "${YELLOW}============================================${NC}"
echo -e "${YELLOW}       YOUTUBE SHORTS DOWNLOADER${NC}"
echo -e "${YELLOW}============================================${NC}"
echo

# Ask for URL
echo "Paste a single Short URL or a channel's Shorts page URL."
echo
echo "Single Short  : https://www.youtube.com/shorts/XXXXXXXXXXX"
echo "Channel Shorts: https://www.youtube.com/@ChannelName/shorts"
echo
read -rp "Paste URL here: " URL

if [ -z "$URL" ]; then
    echo "ERROR: No URL entered."
    read -n 1 -s -r -p "Press any key to continue..."
    exit 1
fi

if [[ ! "$URL" =~ ^https?:// ]]; then
    echo "ERROR: Invalid URL format."
    read -n 1 -s -r -p "Press any key to continue..."
    exit 1
fi

# Save location
if [ -z "$SAVE_DIR" ]; then
    echo
    read -rp "Output folder (leave blank for 'Shorts'): " SAVE_DIR
    if [ -z "$SAVE_DIR" ]; then
        SAVE_DIR="$HOME/Shorts"
    fi
fi

mkdir -p "$SAVE_DIR" || { echo "ERROR: Failed to create save directory '$SAVE_DIR'." >&2; exit 1; }
echo "Save location: $SAVE_DIR"

# Detect if bulk or single
echo
echo "Download type:"
echo "  1. Single Short (default)"
echo "  2. All Shorts from a channel page"
echo
read -rp "Choose type (1-2, default=1): " DTYPE

if [ "$DTYPE" = "2" ]; then
    BULK="yes"
else
    BULK="no"
fi

# Download range only for bulk
if [ "$BULK" = "yes" ]; then
    echo
    echo "Download range (useful for large channels):"
    echo "  Leave blank to download ALL shorts"
    echo "  Example: enter  1-20  to download first 20 shorts"
    echo
    read -rp "Enter range (or leave blank for all): " RANGE
    
    if [ -z "$RANGE" ]; then
        RANGEFLAGS=()
    else
        if ! [[ "$RANGE" =~ ^[0-9,-]+$ ]]; then
            echo "ERROR: Invalid range format. Only digits, commas, and hyphens are allowed." >&2
            read -n 1 -s -r -p "Press any key to continue..."
            exit 1
        fi
        RANGEFLAGS=("--playlist-items" "$RANGE")
    fi
else
    RANGEFLAGS=()
fi

# Quality
echo
echo "Quality options:"
echo "  1. Best (default)"
echo "  2. 2160p (4K)"
echo "  3. 1440p (2K)"
echo "  4. 1080p"
echo "  5. 720p"
echo "  6. 480p"
echo "  7. 360p"
echo
read -rp "Choose quality (1-7, default=1): " QCHOICE

if [ "$QCHOICE" = "2" ]; then
    FHEIGHT="2160"
elif [ "$QCHOICE" = "3" ]; then
    FHEIGHT="1440"
elif [ "$QCHOICE" = "4" ]; then
    FHEIGHT="1080"
elif [ "$QCHOICE" = "5" ]; then
    FHEIGHT="720"
elif [ "$QCHOICE" = "6" ]; then
    FHEIGHT="480"
elif [ "$QCHOICE" = "7" ]; then
    FHEIGHT="360"
else
    FHEIGHT="best"
fi

# Check FFmpeg requirements
if ! command -v ffmpeg >/dev/null 2>&1; then
    echo -e "${YELLOW}WARNING: ffmpeg not found. Some video formats may not merge correctly.${NC}"
fi

echo
echo -e "${YELLOW}============================================${NC}"
echo -e "${YELLOW} Downloading...${NC}"
echo -e "${YELLOW} URL    : $URL${NC}"
echo -e "${YELLOW} Output : $SAVE_DIR${NC}"
echo -e "${YELLOW} Quality: $FHEIGHT${NC}"
echo -e "${YELLOW} Bulk   : $BULK${NC}"
echo -e "${YELLOW}============================================${NC}"
echo

# Build format string
if [ "$FHEIGHT" = "best" ]; then
    FMTSTR="bestvideo+bestaudio/best"
else
    FMTSTR="bestvideo[height<=$FHEIGHT]+bestaudio/best[height<=$FHEIGHT]"
fi

# Cookies support
COOKIEFLAGS=()
if [ -f "$HOME/youtube_cookies.txt" ]; then
    COOKIEFLAGS=("--cookies" "$HOME/youtube_cookies.txt")
elif [ -f "cookies.txt" ]; then
    COOKIEFLAGS=("--cookies" "cookies.txt")
fi

# Single short
if [ "$BULK" = "no" ]; then
    set +e
    yt-dlp \
        --remote-components ejs:github \
        "${COOKIEFLAGS[@]}" \
        -f "$FMTSTR" \
        --merge-output-format mp4 \
        --embed-metadata \
        --embed-thumbnail \
        --retries 5 \
        --fragment-retries 5 \
        -c --part \
        --no-overwrites \
        -o "$SAVE_DIR/%(title).150s.%(ext)s" \
        "$URL"
    ERROR_CODE=$?
    set -e
else
    # Bulk shorts from channel
    set +e
    yt-dlp \
        --remote-components ejs:github \
        "${COOKIEFLAGS[@]}" \
        --yes-playlist \
        -f "$FMTSTR" \
        "${RANGEFLAGS[@]}" \
        --merge-output-format mp4 \
        --embed-metadata \
        --embed-thumbnail \
        --retries 5 \
        --fragment-retries 5 \
        -c --part \
        --no-overwrites \
        --download-archive "archive.txt" \
        -o "$SAVE_DIR/%(playlist_index)s - %(title).150s.%(ext)s" \
        "$URL"
    ERROR_CODE=$?
    set -e
fi

echo
if [ "$ERROR_CODE" -ne 0 ]; then
    echo -e "${YELLOW}============================================${NC}"
    echo -e "${YELLOW} Download FAILED. Check errors above.${NC}"
    echo -e "${YELLOW}============================================${NC}"
else
    echo -e "${YELLOW}============================================${NC}"
    echo -e "${YELLOW} Download COMPLETE!${NC}"
    echo -e "${YELLOW} Files saved in: $SAVE_DIR${NC}"
    echo -e "${YELLOW}============================================${NC}"
    if command -v open >/dev/null 2>&1; then
        open "$SAVE_DIR"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$SAVE_DIR"
    fi
fi

echo
read -n 1 -s -r -p "Press any key to continue..."
