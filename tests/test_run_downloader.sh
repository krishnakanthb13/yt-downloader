#!/bin/bash
# Tests for run_downloader.sh (master menu)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helpers.sh"

SCRIPT="$PROJECT_DIR/run_downloader.sh"

echo "============================================"
echo " run_downloader.sh Tests"
echo "============================================"
echo ""

# ── Menu Display ─────────────────────────────────────
echo "--- Menu Display ---"

assert_file_contains "shows title" "$SCRIPT" "YOUTUBE DOWNLOADER SUITE"
assert_file_contains "shows option 1 label" "$SCRIPT" "Single Video Downloader"
assert_file_contains "shows option 2 label" "$SCRIPT" "YouTube Shorts Downloader"
assert_file_contains "shows option 3 label" "$SCRIPT" "Bulk Downloader"
assert_file_contains "shows option 4 label" "$SCRIPT" "Update yt-dlp"
assert_file_contains "shows exit option" "$SCRIPT" "Exit"
assert_file_contains "prompts for choice" "$SCRIPT" 'read -rp.*MCHOICE\|read -rp.*choice'
echo ""

# ── Option 1: Single Video Downloader ────────────────
echo "--- Option 1: Calls youtube_download.sh ---"

assert_file_contains "option 1 calls youtube_download.sh" "$SCRIPT" "bash youtube_download.sh"
echo ""

# ── Option 2: YouTube Shorts Downloader ──────────────
echo "--- Option 2: Calls youtube_shorts_download.sh ---"

assert_file_contains "option 2 calls youtube_shorts_download.sh" "$SCRIPT" "bash youtube_shorts_download.sh"
echo ""

# ── Option 3: Bulk Downloader ───────────────────────
echo "--- Option 3: Calls youtube_bulk_download.sh ---"

assert_file_contains "option 3 calls youtube_bulk_download.sh" "$SCRIPT" "bash youtube_bulk_download.sh"
echo ""

# ── Option 4: Update yt-dlp ─────────────────────────
echo "--- Option 4: Update yt-dlp Logic ---"

assert_file_contains "option 4 tries pip3 upgrade" "$SCRIPT" "pip3.*install.*yt-dlp\|pip.*install.*yt-dlp"
assert_file_contains "option 4 tries pipx upgrade" "$SCRIPT" "pipx.*upgrade.*yt-dlp"
assert_file_contains "option 4 tries yt-dlp self-update" "$SCRIPT" "yt-dlp -U"
assert_file_contains "option 4 tries python3 -m pip" "$SCRIPT" "python3 -m pip"
assert_file_contains "option 4 tries python -m pip" "$SCRIPT" "python -m pip"
echo ""

# ── Exit Option ──────────────────────────────────────
echo "--- Exit Option ---"

assert_file_contains "option 0 exits" "$SCRIPT" "exit 0"
echo ""

# ── Invalid Option ───────────────────────────────────
echo "--- Invalid Option ---"

assert_file_contains "shows error for invalid choice" "$SCRIPT" "Invalid choice"
assert_file_contains "prompts to try again" "$SCRIPT" "try again"
echo ""

# ── Directory Navigation ─────────────────────────────
echo "--- Directory Navigation ---"

assert_file_contains "changes to script directory" "$SCRIPT" 'cd "\$(dirname "\$0")"'
echo ""

# ── Menu Loop ────────────────────────────────────────
echo "--- Menu Loop ---"

assert_file_contains "uses infinite loop" "$SCRIPT" "while true"
assert_file_contains "clears screen on each iteration" "$SCRIPT" "clear"
echo ""

# ── Child Script Calls ──────────────────────────────
echo "--- Child Script Calls ---"

assert_file_contains "calls youtube_download.sh" "$SCRIPT" "youtube_download.sh"
assert_file_contains "calls youtube_shorts_download.sh" "$SCRIPT" "youtube_shorts_download.sh"
assert_file_contains "calls youtube_bulk_download.sh" "$SCRIPT" "youtube_bulk_download.sh"
echo ""

# ── Color Settings ───────────────────────────────────
echo "--- Color Settings ---"

assert_file_contains "sets green color" "$SCRIPT" "color 0A\|GREEN"
echo ""

print_summary
