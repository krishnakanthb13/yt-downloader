#!/bin/bash
set -euo pipefail
trap 'echo; echo "Cancelled."; exit 130' INT

# Change to script directory
cd "$(dirname "$0")" || exit

# ANSI Colors
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check that yt-dlp exists
if ! command -v yt-dlp >/dev/null 2>&1; then
    echo -e "${CYAN}ERROR: yt-dlp is not installed.${NC}"
    echo "Run option 4 from the main menu first."
    exit 1
fi


# Detect internet connection
if ! command -v curl >/dev/null 2>&1 || ! curl --connect-timeout 5 -A "Mozilla/5.0" -Is https://www.youtube.com >/dev/null 2>&1; then
    echo -e "${CYAN}WARNING: Could not connect to youtube.com. You may be offline.${NC}"
fi

# ============================================
# DEFAULT SAVE LOCATION
# Set SAVE_DIR in downloader.conf (see downloader.conf.example).
# Leave it blank to be asked every time you run this script.
# ============================================
SAVE_DIR=""
if [ -f "downloader.conf" ]; then
    SAVE_DIR="$(sed -n 's/^[[:space:]]*SAVE_DIR[[:space:]]*=[[:space:]]*//p' downloader.conf | tail -n 1 | sed -e 's/[[:space:]]*$//')"
fi

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

if [[ ! "$URL" =~ ^https?:// ]]; then
    echo "ERROR: Invalid URL format."
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

mkdir -p "$SAVE_DIR" || { echo "ERROR: Failed to create save directory '$SAVE_DIR'." >&2; exit 1; }
echo "Save location: $SAVE_DIR"

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
echo "  8. Audio only (mp3)"
echo
read -rp "Choose quality (1-8, default=1): " QCHOICE

AUDIOONLY="no"
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
elif [ "$QCHOICE" = "8" ]; then
    FHEIGHT="best"
    AUDIOONLY="yes"
else
    FHEIGHT="best"
fi

# Check FFmpeg requirements
if ! command -v ffmpeg >/dev/null 2>&1; then
    if [ "$AUDIOONLY" = "yes" ]; then
        echo -e "${CYAN}ERROR: ffmpeg is required for audio extraction (mp3) but was not found.${NC}"
        read -n 1 -s -r -p "Press any key to continue..."
        exit 1
    else
        echo -e "${CYAN}WARNING: ffmpeg not found. Some video formats may not merge correctly.${NC}"
    fi
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

# Cookies support
COOKIEFLAGS=()
if [ -f "$HOME/youtube_cookies.txt" ]; then
    COOKIEFLAGS=("--cookies" "$HOME/youtube_cookies.txt")
elif [ -f "cookies.txt" ]; then
    COOKIEFLAGS=("--cookies" "cookies.txt")
fi

# JavaScript runtime support
# yt-dlp enables Deno by default; enable Node.js when Deno is not installed.
JSFLAGS=()
if ! command -v deno >/dev/null 2>&1 && command -v node >/dev/null 2>&1; then
    JSFLAGS=("--js-runtimes" "node")
fi

# Download execution
if [ "$AUDIOONLY" = "yes" ]; then
    set +e
    yt-dlp \
        --remote-components ejs:github \
        "${COOKIEFLAGS[@]+"${COOKIEFLAGS[@]}"}" \
        "${JSFLAGS[@]+"${JSFLAGS[@]}"}" \
        --no-playlist \
        -x --audio-format mp3 --audio-quality 0 \
        --retries 5 \
        --fragment-retries 5 \
        -c --part \
        --no-overwrites \
        --match-filter "!is_live" \
        -o "$SAVE_DIR/%(title).150s.%(ext)s" \
        "$URL"
    ERROR_CODE=$?
    set -e
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

    set +e
    yt-dlp \
        --remote-components ejs:github \
        "${COOKIEFLAGS[@]+"${COOKIEFLAGS[@]}"}" \
        "${JSFLAGS[@]+"${JSFLAGS[@]}"}" \
        -f "$FMTSTR" \
        "${SUBFLAGS[@]+"${SUBFLAGS[@]}"}" \
        --no-playlist \
        --merge-output-format mp4 \
        --embed-metadata \
        --embed-thumbnail \
        --retries 5 \
        --fragment-retries 5 \
        -c --part \
        --no-overwrites \
        --match-filter "!is_live" \
        -o "$SAVE_DIR/%(title).150s.%(ext)s" \
        "$URL"
    ERROR_CODE=$?
    set -e
fi

echo
if [ "$ERROR_CODE" -ne 0 ]; then
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN} Download FAILED. Check errors above.${NC}"
    echo -e "${CYAN}============================================${NC}"
else
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN} Download COMPLETE!${NC}"
    echo -e "${CYAN} File saved in: $SAVE_DIR${NC}"
    echo -e "${CYAN}============================================${NC}"
    if command -v open >/dev/null 2>&1; then
        open "$SAVE_DIR" || true
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$SAVE_DIR" || true
    fi
fi

echo
read -n 1 -s -r -p "Press any key to continue..."
