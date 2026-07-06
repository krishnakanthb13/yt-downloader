#!/bin/bash
# Tests for youtube_shorts_download.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helpers.sh"

SCRIPT="$PROJECT_DIR/youtube_shorts_download.sh"

echo "============================================"
echo " youtube_shorts_download.sh Tests"
echo "============================================"
echo ""

# ── Quality Selection Logic ──────────────────────────
echo "--- Quality Selection Logic ---"

assert_file_contains "choice 1 -> FHEIGHT=best" "$SCRIPT" 'FHEIGHT="best"'
assert_file_contains "choice 2 -> FHEIGHT=2160" "$SCRIPT" 'FHEIGHT="2160"'
assert_file_contains "choice 3 -> FHEIGHT=1440" "$SCRIPT" 'FHEIGHT="1440"'
assert_file_contains "choice 4 -> FHEIGHT=1080" "$SCRIPT" 'FHEIGHT="1080"'
assert_file_contains "choice 5 -> FHEIGHT=720" "$SCRIPT" 'FHEIGHT="720"'
assert_file_contains "choice 6 -> FHEIGHT=480" "$SCRIPT" 'FHEIGHT="480"'
assert_file_contains "choice 7 -> FHEIGHT=360" "$SCRIPT" 'FHEIGHT="360"'
assert_file_contains "default -> FHEIGHT=best" "$SCRIPT" 'FHEIGHT="best"'
echo ""

# ── Download Type Selection ──────────────────────────
echo "--- Download Type Selection ---"

assert_file_contains "shows download type menu" "$SCRIPT" "Download type"
assert_file_contains "shows single short option" "$SCRIPT" "Single Short"
assert_file_contains "shows bulk option" "$SCRIPT" "All Shorts from a channel"
assert_file_contains "sets BULK=yes for type 2" "$SCRIPT" 'BULK="yes"'
assert_file_contains "sets BULK=no for type 1" "$SCRIPT" 'BULK="no"'
echo ""

# ── Single Short Download ────────────────────────────
echo "--- Single Short Download ---"

assert_file_contains "single short: no --yes-playlist" "$SCRIPT" 'if \[ "\$BULK" = "no" \]'
assert_file_contains "single short: output uses title" "$SCRIPT" 'title).150s'
echo ""

# ── Bulk Shorts Download ─────────────────────────────
echo "--- Bulk Shorts Download ---"

assert_file_contains "bulk: uses --yes-playlist" "$SCRIPT" "yes-playlist"
assert_file_contains "bulk: uses download-archive" "$SCRIPT" "download-archive"
assert_file_contains "bulk: output uses playlist_index" "$SCRIPT" "playlist_index"
echo ""

# ── Download Range (Bulk Only) ───────────────────────
echo "--- Download Range ---"

assert_file_contains "shows range prompt for bulk" "$SCRIPT" "Enter range"
assert_file_contains "uses --playlist-items" "$SCRIPT" "playlist-items"
assert_file_contains "validates range format" "$SCRIPT" '\^\[0-9,-\]'
assert_file_contains "rejects invalid range" "$SCRIPT" "Invalid range format"
echo ""

# ── Format String Building ───────────────────────────
echo "--- Format String Building ---"

assert_file_contains "best quality format" "$SCRIPT" 'bestvideo+bestaudio/best'
assert_file_contains "specific quality format" "$SCRIPT" 'bestvideo\[height<='
echo ""

# ── Output Options ───────────────────────────────────
echo "--- Output Options ---"

assert_file_contains "embeds metadata" "$SCRIPT" "embed-metadata"
assert_file_contains "embeds thumbnail" "$SCRIPT" "embed-thumbnail"
assert_file_contains "merges to mp4" "$SCRIPT" "merge-output-format mp4"
assert_file_contains "skips overwrites" "$SCRIPT" "no-overwrites"
echo ""

# ── Download Success/Failure Messages ────────────────
echo "--- Download Status Messages ---"

assert_file_contains "shows completion message" "$SCRIPT" "Download COMPLETE"
assert_file_contains "shows failure message" "$SCRIPT" "Download FAILED"
assert_file_contains "shows files saved message" "$SCRIPT" "Files saved in"
assert_file_contains "opens folder on completion" "$SCRIPT" "open.*SAVE_DIR\|xdg-open.*SAVE_DIR"
echo ""

# ── Retry Logic ──────────────────────────────────────
echo "--- Retry Logic ---"

assert_file_contains "has --retries 5" "$SCRIPT" "retries 5"
assert_file_contains "has --fragment-retries 5" "$SCRIPT" "fragment-retries 5"
echo ""

# ── URL Variations ───────────────────────────────────
echo "--- URL Variations ---"

assert_file_contains "shows shorts URL example" "$SCRIPT" "shorts/"
assert_file_contains "shows channel shorts URL" "$SCRIPT" "@ChannelName/shorts"
assert_file_contains "validates URL not empty" "$SCRIPT" 'if \[ -z "\$URL" \]'
assert_file_contains "validates URL format" "$SCRIPT" 'https?://'
echo ""

# ── Internet Connection Check ────────────────────────
echo "--- Internet Connection Check ---"

assert_file_contains "checks internet connection" "$SCRIPT" "curl.*youtube.com"
assert_file_contains "warns when offline" "$SCRIPT" "Could not connect"
echo ""

# ── Cookie Support ───────────────────────────────────
echo "--- Cookie Support ---"

assert_file_contains "checks user profile cookies" "$SCRIPT" 'HOME.*youtube_cookies.txt'
assert_file_contains "checks local cookies" "$SCRIPT" 'cookies.txt'
echo ""

# ── Save Directory ───────────────────────────────────
echo "--- Save Directory ---"

assert_file_contains "prompts for save directory" "$SCRIPT" 'read -rp.*SAVE_DIR\|read -rp.*folder'
assert_file_contains "defaults to Shorts" "$SCRIPT" 'SAVE_DIR="\$HOME/Shorts"'
assert_file_contains "creates directory if missing" "$SCRIPT" 'mkdir -p'
echo ""

# ── FFmpeg Handling ──────────────────────────────────
echo "--- FFmpeg Handling ---"

assert_file_contains "checks for ffmpeg" "$SCRIPT" "command -v ffmpeg"
assert_file_contains "warns when ffmpeg missing" "$SCRIPT" "ffmpeg not found"
echo ""

# ── Window Title ─────────────────────────────────────
echo "--- Window Title ---"

assert_file_contains "displays title" "$SCRIPT" "YOUTUBE SHORTS DOWNLOADER"
echo ""

print_summary
