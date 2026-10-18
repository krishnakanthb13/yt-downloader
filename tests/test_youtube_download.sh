#!/bin/bash
# Tests for youtube_download.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helpers.sh"

SCRIPT="$PROJECT_DIR/youtube_download.sh"

echo "============================================"
echo " youtube_download.sh Tests"
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

# ── Format String Building ───────────────────────────
echo "--- Format String Building ---"

assert_file_contains "best quality format" "$SCRIPT" 'bestvideo+bestaudio/best'
assert_file_contains "specific quality format with height filter" "$SCRIPT" 'bestvideo\[height<='
assert_file_contains "fallback format with height filter" "$SCRIPT" 'best\[height<='
echo ""

# ── Output Options ───────────────────────────────────
echo "--- Output Options ---"

assert_file_contains "embeds metadata" "$SCRIPT" "embed-metadata"
assert_file_contains "embeds thumbnail" "$SCRIPT" "embed-thumbnail"
assert_file_contains "merges to mp4" "$SCRIPT" "merge-output-format mp4"
assert_file_contains "has retries" "$SCRIPT" "retries 5"
assert_file_contains "has fragment retries" "$SCRIPT" "fragment-retries 5"
assert_file_contains "continues on error" "$SCRIPT" "\-c --part"
assert_file_contains "skips overwrites" "$SCRIPT" "no-overwrites"
assert_file_contains "skips live streams" "$SCRIPT" "is_live"
echo ""

# ── Retry Logic ──────────────────────────────────────
echo "--- Retry Logic ---"

assert_file_contains "has --retries 5" "$SCRIPT" "retries 5"
assert_file_contains "has --fragment-retries 5" "$SCRIPT" "fragment-retries 5"
echo ""

# ── Download Success/Failure Messages ────────────────
echo "--- Download Status Messages ---"

assert_file_contains "shows completion message" "$SCRIPT" "Download COMPLETE"
assert_file_contains "shows failure message" "$SCRIPT" "Download FAILED"
assert_file_contains "shows file saved message" "$SCRIPT" "File saved in"
assert_file_contains "opens folder on completion" "$SCRIPT" "open.*SAVE_DIR\|xdg-open.*SAVE_DIR"
echo ""

# ── URL Handling ─────────────────────────────────────
echo "--- URL Handling ---"

assert_file_contains "prompts for URL" "$SCRIPT" 'read -rp.*URL'
assert_file_contains "validates URL not empty" "$SCRIPT" 'if \[ -z "\$URL" \]'
assert_file_contains "validates URL format" "$SCRIPT" 'https?://'
assert_file_contains "shows URL example" "$SCRIPT" "watch?v="
echo ""

# ── Single Video (no playlist flags) ─────────────────
echo "--- Single Video Mode ---"

assert_file_not_contains "does not use --yes-playlist" "$SCRIPT" "yes-playlist"
assert_file_not_contains "does not use --download-archive" "$SCRIPT" "download-archive"
assert_file_not_contains "does not use --playlist-items" "$SCRIPT" "playlist-items"
echo ""

# ── Output File Naming ───────────────────────────────
echo "--- Output File Naming ---"

assert_file_contains "output uses title in filename" "$SCRIPT" 'title).150s'
assert_file_contains "output uses ext placeholder" "$SCRIPT" 'ext)s'
echo ""

# ── Live Stream Filtering ────────────────────────────
echo "--- Live Stream Filtering ---"

assert_file_contains "filters out live streams" "$SCRIPT" '!is_live'
echo ""

# ── Cookie Support ───────────────────────────────────
echo "--- Cookie Support ---"

assert_file_contains "checks user profile cookies" "$SCRIPT" 'HOME.*youtube_cookies.txt'
assert_file_contains "checks local cookies" "$SCRIPT" 'cookies.txt'
assert_file_contains "passes cookies to yt-dlp" "$SCRIPT" '\-\-cookies'
echo ""

# ── Save Directory ───────────────────────────────────
echo "--- Save Directory ---"

assert_file_contains "prompts for save directory" "$SCRIPT" 'read -rp.*SAVE_DIR\|read -rp.*folder'
assert_file_contains "defaults to Downloads" "$SCRIPT" 'SAVE_DIR="\$HOME/Downloads"'
assert_file_contains "creates directory if missing" "$SCRIPT" 'mkdir -p'
echo ""

# ── Internet Connection Check ────────────────────────
echo "--- Internet Connection Check ---"

assert_file_contains "checks internet connection" "$SCRIPT" "curl.*youtube.com"
assert_file_contains "warns when offline" "$SCRIPT" "Could not connect"
echo ""

# ── Window Title ─────────────────────────────────────
echo "--- Window Title ---"

assert_file_contains "displays title" "$SCRIPT" "YOUTUBE VIDEO DOWNLOADER"
echo ""

# ── Config-driven save directory (functional) ────────
echo "--- Config-Driven Save Directory (functional) ---"

setup_test_env
cp "$SCRIPT" "$TEST_TMPDIR/youtube_download.sh"
printf 'SAVE_DIR=%s/MyMovies\n' "$TEST_TMPDIR" > "$TEST_TMPDIR/downloader.conf"
run_with_mock_ytdlp "$TEST_TMPDIR/youtube_download.sh" "https://youtu.be/abc123\n1\n1\n"

TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "MyMovies" "$TEST_TMPDIR/ytdlp_mock.log" 2>/dev/null; then
    echo -e "  ${GREEN}PASS${NC}: save directory is read from downloader.conf"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "  ${RED}FAIL${NC}: save directory was not read from downloader.conf"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

TESTS_RUN=$((TESTS_RUN + 1))
if grep -q -- "--no-playlist" "$TEST_TMPDIR/ytdlp_mock.log" 2>/dev/null; then
    echo -e "  ${GREEN}PASS${NC}: single video is downloaded with --no-playlist"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "  ${RED}FAIL${NC}: single video is missing --no-playlist"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
cleanup_test_env
echo ""

print_summary
