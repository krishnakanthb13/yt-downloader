#!/bin/bash

# Change to script directory
cd "$(dirname "$0")" || exit

# ANSI Colors
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================
# HARDCODE YOUR SAVE LOCATION HERE
# Example: SAVE_DIR="$HOME/YouTube Downloads"
# Leave blank to be asked every time
# ============================================
SAVE_DIR=""

# ============================================

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}        YOUTUBE VIDEO DOWNLOADER${NC}"
echo -e "${CYAN}============================================${NC}"
echo

# Ask for URL
echo "Paste the YouTube video URL."
echo "Example: https://www.youtube.com/watch?v=XXXXXXXXXXX"
echo
read -rp "Paste URL here: " URL

if [ -z "$URL" ]; then
    echo "ERROR: No URL entered."
    read -n 1 -s -r -p "Press any key to continue..."
    exit 1
fi

# Save location
if [ -z "$SAVE_DIR" ]; then
    echo
    read -rp "Output folder (leave blank for 'Downloads'): " SAVE_DIR
    if [ -z "$SAVE_DIR" ]; then
        SAVE_DIR="$HOME/Downloads"
    fi
fi

if [ ! -d "$SAVE_DIR" ]; then
    if ! mkdir -p "$SAVE_DIR"; then
        echo "ERROR: Failed to create save directory '$SAVE_DIR'." >&2
        exit 1
    fi
fi
echo "Save location: $SAVE_DIR"

# Quality
echo
echo "Quality options:"
echo "  1. Best (default)"
echo "  2. 1080p"
echo "  3. 720p"
echo "  4. 480p"
echo "  5. 360p"
echo "  6. Audio only (mp3)"
echo
read -rp "Choose quality (1-6, default=1): " QCHOICE

AUDIOONLY="no"
if [ "$QCHOICE" = "2" ]; then
    FHEIGHT="1080"
elif [ "$QCHOICE" = "3" ]; then
    FHEIGHT="720"
elif [ "$QCHOICE" = "4" ]; then
    FHEIGHT="480"
elif [ "$QCHOICE" = "5" ]; then
    FHEIGHT="360"
elif [ "$QCHOICE" = "6" ]; then
    FHEIGHT="best"
    AUDIOONLY="yes"
else
    FHEIGHT="best"
fi

# Subtitles (skip if audio only)
if [ "$AUDIOONLY" = "no" ]; then
    echo
    echo "Subtitle options:"
    echo "  1. No subtitles (default)"
    echo "  2. English"
    echo "  3. Tamil"
    echo "  4. All available"
    echo
    read -rp "Download subtitles? (1-4, default=1): " SCHOICE

    if [ "$SCHOICE" = "2" ]; then
        SUBLANG="en"
    elif [ "$SCHOICE" = "3" ]; then
        SUBLANG="ta"
    elif [ "$SCHOICE" = "4" ]; then
        SUBLANG="all"
    else
        SUBLANG="none"
    fi
else
    SUBLANG="none"
fi

echo
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN} Downloading...${NC}"
echo -e "${CYAN} URL     : $URL${NC}"
echo -e "${CYAN} Output  : $SAVE_DIR${NC}"
echo -e "${CYAN} Quality : $FHEIGHT${NC}"
echo -e "${CYAN}============================================${NC}"
echo

# Download execution
if [ "$AUDIOONLY" = "yes" ]; then
    yt-dlp \
        --remote-components ejs:github \
        -x --audio-format mp3 --audio-quality 0 \
        --retries 5 \
        --fragment-retries 5 \
        --continue \
        --no-overwrites \
        -o "$SAVE_DIR/%(title)s.%(ext)s" \
        "$URL"
    ERROR_CODE=$?
else
    # Build format string
    if [ "$FHEIGHT" = "best" ]; then
        FMTSTR="bestvideo+bestaudio/best"
    else
        FMTSTR="bestvideo[height<=$FHEIGHT]+bestaudio/best[height<=$FHEIGHT]"
    fi

    # Build subtitle flags
    if [ "$SUBLANG" = "none" ]; then
        SUBFLAGS=()
    elif [ "$SUBLANG" = "all" ]; then
        SUBFLAGS=("--write-subs" "--write-auto-subs" "--sub-langs" "all")
    else
        SUBFLAGS=("--write-subs" "--write-auto-subs" "--sub-langs" "$SUBLANG")
    fi

    yt-dlp \
        --remote-components ejs:github \
        -f "$FMTSTR" \
        "${SUBFLAGS[@]}" \
        --merge-output-format mp4 \
        --retries 5 \
        --fragment-retries 5 \
        --continue \
        --no-overwrites \
        -o "$SAVE_DIR/%(title)s.%(ext)s" \
        "$URL"
    ERROR_CODE=$?
fi

echo
if [ $ERROR_CODE -ne 0 ]; then
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN} Download FAILED. Check errors above.${NC}"
    echo -e "${CYAN}============================================${NC}"
else
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN} Download COMPLETE!${NC}"
    echo -e "${CYAN} File saved in: $SAVE_DIR${NC}"
    echo -e "${CYAN}============================================${NC}"
    if command -v open >/dev/null 2>&1; then
        open "$SAVE_DIR"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$SAVE_DIR"
    fi
fi

echo
read -n 1 -s -r -p "Press any key to continue..."
