#!/bin/bash
# Common tests shared across all shell scripts
# Tests features present in all download scripts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helpers.sh"

echo "============================================"
echo " Common Tests (all download scripts)"
echo "============================================"
echo ""

# ── Syntax validation ────────────────────────────────
echo "--- Script Syntax Validation ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh run_downloader.sh; do
    TESTS_RUN=$((TESTS_RUN + 1))
    if bash -n "$PROJECT_DIR/$script" 2>/dev/null; then
        echo -e "  ${GREEN}PASS${NC}: $script has valid bash syntax"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}FAIL${NC}: $script has syntax errors"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done
echo ""

# ── Scripts have shebangs ────────────────────────────
echo "--- Shebang Lines ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh run_downloader.sh; do
    assert_file_contains "$script has bash shebang" "$PROJECT_DIR/$script" "^#!/bin/bash$"
done
echo ""

# ── Scripts use set -euo pipefail ────────────────────
echo "--- Error Handling Flags ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh; do
    assert_file_contains "$script uses set -euo pipefail" "$PROJECT_DIR/$script" "set -euo pipefail"
done
echo ""

# ── Scripts have INT trap ────────────────────────────
echo "--- Signal Handling ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh; do
    assert_file_contains "$script traps SIGINT" "$PROJECT_DIR/$script" "trap.*INT"
done
echo ""

# ── Scripts change to their own directory ────────────
echo "--- Directory Navigation ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh run_downloader.sh; do
    assert_file_contains "$script changes to script directory" "$PROJECT_DIR/$script" 'cd "\$(dirname "\$0")"'
done
echo ""

# ── yt-dlp existence checks ─────────────────────────
echo "--- yt-dlp Installation Check ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh; do
    assert_file_contains "$script checks for yt-dlp" "$PROJECT_DIR/$script" "command -v yt-dlp"
    assert_file_contains "$script shows error when yt-dlp missing" "$PROJECT_DIR/$script" "yt-dlp is not installed"
    assert_file_contains "$script exits with code 1 when yt-dlp missing" "$PROJECT_DIR/$script" "exit 1"
done
echo ""

# ── FFmpeg checks ────────────────────────────────────
echo "--- FFmpeg Warning ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh; do
    assert_file_contains "$script checks for ffmpeg" "$PROJECT_DIR/$script" "command -v ffmpeg"
    assert_file_contains "$script warns when ffmpeg missing" "$PROJECT_DIR/$script" "ffmpeg not found"
done
echo ""

# ── Empty URL rejection ──────────────────────────────
echo "--- Empty URL Rejection ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh; do
    assert_file_contains "$script rejects empty URL" "$PROJECT_DIR/$script" 'if \[ -z "\$URL" \]'
    assert_file_contains "$script shows error for empty URL" "$PROJECT_DIR/$script" "ERROR: No URL entered"
done
echo ""

# ── Invalid URL format ──────────────────────────────
echo "--- Invalid URL Format ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh; do
    assert_file_contains "$script validates URL format" "$PROJECT_DIR/$script" 'https?://'
    assert_file_contains "$script shows error for invalid URL" "$PROJECT_DIR/$script" "Invalid URL format"
done
echo ""

# ── Cookie file detection ───────────────────────────
echo "--- Cookie Detection ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh; do
    assert_file_contains "$script checks for home cookies" "$PROJECT_DIR/$script" 'youtube_cookies.txt'
    assert_file_contains "$script checks for local cookies" "$PROJECT_DIR/$script" 'cookies.txt'
    assert_file_contains "$script uses cookies flag" "$PROJECT_DIR/$script" 'cookies.*txt'
done
echo ""

# ── Save directory creation ──────────────────────────
echo "--- Save Directory Creation ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh; do
    assert_file_contains "$script creates save directory" "$PROJECT_DIR/$script" 'mkdir -p'
done
echo ""

# ── Quality options ──────────────────────────────────
echo "--- Quality Options ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh; do
    assert_file_contains "$script shows quality menu" "$PROJECT_DIR/$script" "Quality options"
    assert_file_contains "$script has best quality option" "$PROJECT_DIR/$script" "Best (default)"
    assert_file_contains "$script has 2160p option" "$PROJECT_DIR/$script" "2160p"
    assert_file_contains "$script has 1080p option" "$PROJECT_DIR/$script" "1080p"
    assert_file_contains "$script has 720p option" "$PROJECT_DIR/$script" "720p"
    assert_file_contains "$script has 360p option" "$PROJECT_DIR/$script" "360p"
done
echo ""

# ── Output options ───────────────────────────────────
echo "--- Common Output Options ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh; do
    assert_file_contains "$script embeds metadata" "$PROJECT_DIR/$script" "embed-metadata"
    assert_file_contains "$script embeds thumbnail" "$PROJECT_DIR/$script" "embed-thumbnail"
    assert_file_contains "$script merges to mp4" "$PROJECT_DIR/$script" "merge-output-format mp4"
    assert_file_contains "$script has retry logic" "$PROJECT_DIR/$script" "retries 5"
    assert_file_contains "$script has fragment retries" "$PROJECT_DIR/$script" "fragment-retries 5"
    assert_file_contains "$script skips overwrites" "$PROJECT_DIR/$script" "no-overwrites"
done
# Live stream filtering only in download and bulk (not shorts)
for script in youtube_download.sh youtube_bulk_download.sh; do
    assert_file_contains "$script skips live streams" "$PROJECT_DIR/$script" "is_live"
done
echo ""

# ── Remote components ───────────────────────────────
echo "--- Remote Components ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh; do
    assert_file_contains "$script uses remote components" "$PROJECT_DIR/$script" "remote-components ejs:github"
done
echo ""

# ── ANSI Color codes ────────────────────────────────
echo "--- ANSI Color Codes ---"

for script in youtube_download.sh youtube_bulk_download.sh youtube_shorts_download.sh run_downloader.sh; do
    assert_file_contains "$script defines color variables" "$PROJECT_DIR/$script" "NC=.*No Color"
done
echo ""

print_summary
