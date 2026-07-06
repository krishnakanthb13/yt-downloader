#!/bin/bash
# Tests for youtube_bulk_download.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helpers.sh"

SCRIPT="$PROJECT_DIR/youtube_bulk_download.sh"

echo "============================================"
echo " youtube_bulk_download.sh Tests"
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
assert_file_contains "choice 8 -> AUDIOONLY=yes" "$SCRIPT" 'AUDIOONLY="yes"'
assert_file_contains "default -> FHEIGHT=best" "$SCRIPT" 'FHEIGHT="best"'
echo ""

# ── Audio Only Mode ──────────────────────────────────
echo "--- Audio Only Mode ---"

assert_file_contains "audio-only uses mp3 format" "$SCRIPT" "audio-format mp3"
assert_file_contains "audio-only extracts audio with -x" "$SCRIPT" "\-x --audio-format mp3"
assert_file_contains "audio-only sets AUDIOONLY=yes" "$SCRIPT" 'AUDIOONLY="yes"'
assert_file_contains "audio-only skips subtitle prompt" "$SCRIPT" 'if \[ "\$AUDIOONLY" = "no" \]'
echo ""

# ── Subtitle Options ────────────────────────────────
echo "--- Subtitle Options ---"

assert_file_contains "shows subtitle menu" "$SCRIPT" "Subtitle options"
assert_file_contains "option 2 -> English" "$SCRIPT" 'SUBLANG="en"'
assert_file_contains "option 3 -> Tamil" "$SCRIPT" 'SUBLANG="ta"'
assert_file_contains "option 4 -> All" "$SCRIPT" 'SUBLANG="all"'
assert_file_contains "default -> no subtitles" "$SCRIPT" 'SUBLANG="none"'
assert_file_contains "uses --write-subs" "$SCRIPT" "write-subs"
assert_file_contains "uses --write-auto-subs" "$SCRIPT" "write-auto-subs"
assert_file_contains "uses --sub-langs" "$SCRIPT" "sub-langs"
echo ""

# ── Playlist/Channel Support ─────────────────────────
echo "--- Playlist/Channel Support ---"

assert_file_contains "uses --yes-playlist flag" "$SCRIPT" "yes-playlist"
assert_file_contains "shows playlist URL example" "$SCRIPT" "playlist?list="
assert_file_contains "shows channel URL example" "$SCRIPT" "@ChannelName/videos"
assert_file_contains "uses download archive" "$SCRIPT" "download-archive"
echo ""

# ── Download Range ───────────────────────────────────
echo "--- Download Range ---"

assert_file_contains "shows range prompt" "$SCRIPT" "Enter range"
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
assert_file_contains "skips live streams" "$SCRIPT" "is_live"
echo ""

# ── Archive File ─────────────────────────────────────
echo "--- Download Archive ---"

assert_file_contains "uses download-archive" "$SCRIPT" "download-archive"
assert_file_contains "archive file is archive.txt" "$SCRIPT" 'archive.txt'
echo ""

# ── Output Naming Pattern ────────────────────────────
echo "--- Output Naming Pattern ---"

assert_file_contains "output uses playlist_index" "$SCRIPT" "playlist_index"
assert_file_contains "output uses playlist name in path" "$SCRIPT" "playlist)s"
assert_file_contains "output uses title truncation" "$SCRIPT" 'title).150s'
echo ""

# ── Download Success/Failure Messages ────────────────
echo "--- Download Status Messages ---"

assert_file_contains "shows completion message" "$SCRIPT" "All downloads COMPLETE"
assert_file_contains "shows failure message" "$SCRIPT" "Some downloads may have FAILED"
assert_file_contains "shows files saved message" "$SCRIPT" "Files saved in"
assert_file_contains "opens folder on completion" "$SCRIPT" "open.*SAVE_DIR\|xdg-open.*SAVE_DIR"
echo ""

# ── Retry Logic ──────────────────────────────────────
echo "--- Retry Logic ---"

assert_file_contains "has --retries 5" "$SCRIPT" "retries 5"
assert_file_contains "has --fragment-retries 5" "$SCRIPT" "fragment-retries 5"
echo ""

# ── Internet Connection Check ────────────────────────
echo "--- Internet Connection Check ---"

assert_file_contains "checks internet connection" "$SCRIPT" "curl.*youtube.com"
assert_file_contains "warns when offline" "$SCRIPT" "Could not connect"
echo ""

# ── URL Handling ─────────────────────────────────────
echo "--- URL Handling ---"

assert_file_contains "prompts for URL" "$SCRIPT" 'read -rp.*URL'
assert_file_contains "validates URL not empty" "$SCRIPT" 'if \[ -z "\$URL" \]'
assert_file_contains "validates URL format" "$SCRIPT" 'https?://'
echo ""

# ── Cookie Support ───────────────────────────────────
echo "--- Cookie Support ---"

assert_file_contains "checks user profile cookies" "$SCRIPT" 'HOME.*youtube_cookies.txt'
assert_file_contains "checks local cookies" "$SCRIPT" 'cookies.txt'
echo ""

# ── Save Directory ───────────────────────────────────
echo "--- Save Directory ---"

assert_file_contains "prompts for save directory" "$SCRIPT" 'read -rp.*SAVE_DIR\|read -rp.*folder'
assert_file_contains "defaults to Downloads" "$SCRIPT" 'SAVE_DIR="\$HOME/Downloads"'
assert_file_contains "creates directory if missing" "$SCRIPT" 'mkdir -p'
echo ""

# ── Window Title ─────────────────────────────────────
echo "--- Window Title ---"

assert_file_contains "displays title" "$SCRIPT" "YOUTUBE BULK DOWNLOADER"
assert_file_contains "shows Playlists and Channels" "$SCRIPT" "Playlists and Channel"
echo ""

print_summary
