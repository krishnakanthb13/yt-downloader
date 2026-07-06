#!/bin/bash
# Shared test utilities for yt-downloader shell script tests

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Create a temporary directory for each test
setup_test_env() {
    TEST_TMPDIR=$(mktemp -d)
    TEST_OUTPUT="$TEST_TMPDIR/output.txt"
}

cleanup_test_env() {
    rm -rf "$TEST_TMPDIR"
}

# Assert that a file contains a pattern (static analysis)
assert_file_contains() {
    local label="$1"
    local filepath="$2"
    local pattern="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if grep -q "$pattern" "$filepath" 2>/dev/null; then
        echo -e "  ${GREEN}PASS${NC}: $label"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}FAIL${NC}: $label (pattern not found: $pattern)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Assert that a file does NOT contain a pattern
assert_file_not_contains() {
    local label="$1"
    local filepath="$2"
    local pattern="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if grep -q "$pattern" "$filepath" 2>/dev/null; then
        echo -e "  ${RED}FAIL${NC}: $label (pattern found but should not be: $pattern)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    else
        echo -e "  ${GREEN}PASS${NC}: $label"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
}

# Assert a file has exactly N occurrences of a pattern
assert_file_count() {
    local label="$1"
    local filepath="$2"
    local pattern="$3"
    local expected="$4"
    TESTS_RUN=$((TESTS_RUN + 1))
    local actual
    actual=$(grep -c "$pattern" "$filepath" 2>/dev/null || echo "0")
    if [ "$actual" = "$expected" ]; then
        echo -e "  ${GREEN}PASS${NC}: $label (count: $actual)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}FAIL${NC}: $label (expected $expected, got $actual)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Assert a variable is set to a specific value in script source
assert_var_value() {
    local label="$1"
    local script_content="$2"
    local var_name="$3"
    local expected_value="$4"
    TESTS_RUN=$((TESTS_RUN + 1))
    if echo "$script_content" | grep -q "$var_name=$expected_value" 2>/dev/null; then
        echo -e "  ${GREEN}PASS${NC}: $label"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}FAIL${NC}: $label ($var_name not set to $expected_value)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Run a script with mocked yt-dlp and verify the arguments it receives
# Returns the mock log contents
run_with_mock_ytdlp() {
    local script="$1"
    local input="$2"
    local mock_log="$TEST_TMPDIR/ytdlp_mock.log"
    local mock_bin="$TEST_TMPDIR/bin"

    mkdir -p "$mock_bin"

    # Create yt-dlp mock that logs its arguments
    cat > "$mock_bin/yt-dlp" << 'MOCK'
#!/bin/bash
echo "$@" >> "${MOCK_LOG:-/tmp/ytdlp_mock.log}"
exit "${YTDLP_MOCK_EXIT:-0}"
MOCK
    chmod +x "$mock_bin/yt-dlp" 2>/dev/null || true

    # Create ffmpeg mock
    cat > "$mock_bin/ffmpeg" << 'MOCK'
#!/bin/bash
exit 0
MOCK
    chmod +x "$mock_bin/ffmpeg" 2>/dev/null || true

    # Create curl mock (simulate online)
    cat > "$mock_bin/curl" << 'MOCK'
#!/bin/bash
exit 0
MOCK
    chmod +x "$mock_bin/curl" 2>/dev/null || true

    export MOCK_LOG="$mock_log"
    rm -f "$mock_log"

    # Run with our mocks first in PATH
    echo -e "$input" | PATH="$mock_bin:$PATH" bash "$script" > "$TEST_OUTPUT" 2>&1 || true
}

# Print test summary
print_summary() {
    echo ""
    echo "============================================"
    echo -e " Tests run: $TESTS_RUN"
    echo -e " ${GREEN}Passed: $TESTS_PASSED${NC}"
    if [ "$TESTS_FAILED" -gt 0 ]; then
        echo -e " ${RED}Failed: $TESTS_FAILED${NC}"
    else
        echo -e " Failed: $TESTS_FAILED"
    fi
    echo "============================================"
    return "$TESTS_FAILED"
}
