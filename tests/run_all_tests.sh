#!/bin/bash
# Main test runner for yt-downloader shell scripts
# Run from the project root or tests/ directory

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

TOTAL_RUN=0
TOTAL_PASSED=0
TOTAL_FAILED=0

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}   yt-downloader Shell Script Test Suite${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# Run each test file
TEST_FILES=(
    "test_common.sh"
    "test_youtube_download.sh"
    "test_youtube_bulk_download.sh"
    "test_youtube_shorts_download.sh"
    "test_run_downloader.sh"
)

for test_file in "${TEST_FILES[@]}"; do
    test_path="$SCRIPT_DIR/$test_file"
    if [ ! -f "$test_path" ]; then
        echo -e "${RED}WARNING: $test_file not found, skipping${NC}"
        continue
    fi

    echo -e "${YELLOW}Running $test_file...${NC}"
    echo ""

    # Run the test and capture its summary
    output=$(bash "$test_path" 2>&1) || true
    echo "$output"

    # Parse results from the output
    file_passed=$(echo "$output" | grep -oP 'Passed: \K[0-9]+' || echo "0")
    file_failed=$(echo "$output" | grep -oP 'Failed: \K[0-9]+' || echo "0")
    file_run=$(echo "$output" | grep -oP 'Tests run: \K[0-9]+' || echo "0")

    TOTAL_RUN=$((TOTAL_RUN + file_run))
    TOTAL_PASSED=$((TOTAL_PASSED + file_passed))
    TOTAL_FAILED=$((TOTAL_FAILED + file_failed))

    echo ""
done

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}   TOTAL RESULTS${NC}"
echo -e "${CYAN}============================================${NC}"
echo -e " Tests run: $TOTAL_RUN"
echo -e " ${GREEN}Passed: $TOTAL_PASSED${NC}"
if [ "$TOTAL_FAILED" -gt 0 ]; then
    echo -e " ${RED}Failed: $TOTAL_FAILED${NC}"
else
    echo -e " Failed: $TOTAL_FAILED"
fi
echo -e "${CYAN}============================================${NC}"
echo ""

exit "$TOTAL_FAILED"
