# PowerShell tests for all .bat files
# Run with: powershell -ExecutionPolicy Bypass -File tests/test_batch_files.ps1

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

# Test counters
$script:TestsRun = 0
$script:TestsPassed = 0
$script:TestsFailed = 0

# Colors
function Write-Pass($msg) { Write-Host "  PASS: $msg" -ForegroundColor Green }
function Write-Fail($msg) { Write-Host "  FAIL: $msg" -ForegroundColor Red }
function Write-Skip($msg) { Write-Host "  SKIP: $msg" -ForegroundColor Yellow }

function Assert-Contains {
    param([string]$Label, [string]$Expected, [string]$Actual)
    $script:TestsRun++
    if ($Actual -match [regex]::Escape($Expected)) {
        Write-Pass $Label
        $script:TestsPassed++
    } else {
        Write-Fail "$Label (expected '$Expected' in output)"
        $script:TestsFailed++
    }
}

function Assert-NotContains {
    param([string]$Label, [string]$Unexpected, [string]$Actual)
    $script:TestsRun++
    if ($Actual -notmatch [regex]::Escape($Unexpected)) {
        Write-Pass $Label
        $script:TestsPassed++
    } else {
        Write-Fail "$Label (unexpected '$Unexpected' found in output)"
        $script:TestsFailed++
    }
}

function Assert-ExitCode {
    param([string]$Label, [int]$Expected, [int]$Actual)
    $script:TestsRun++
    if ($Actual -eq $Expected) {
        Write-Pass "$Label (exit code $Actual)"
        $script:TestsPassed++
    } else {
        Write-Fail "$Label (expected $Expected, got $Actual)"
        $script:TestsFailed++
    }
}

function Assert-FileExists {
    param([string]$Label, [string]$Path)
    $script:TestsRun++
    if (Test-Path $Path) {
        Write-Pass $Label
        $script:TestsPassed++
    } else {
        Write-Fail "$Label (file not found: $Path)"
        $script:TestsFailed++
    }
}

function Print-Summary {
    Write-Host ""
    Write-Host "============================================"
    Write-Host " Tests run: $script:TestsRun"
    Write-Host " Passed: $script:TestsPassed" -ForegroundColor Green
    if ($script:TestsFailed -gt 0) {
        Write-Host " Failed: $script:TestsFailed" -ForegroundColor Red
    } else {
        Write-Host " Failed: $script:TestsFailed"
    }
    Write-Host "============================================"
    return $script:TestsFailed
}

# Create temp directory for tests
$TestTmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "ytdl_test_$(Get-Random)"
New-Item -ItemType Directory -Path $TestTmpDir -Force | Out-Null

try {
    Write-Host "============================================"
    Write-Host " Batch File Tests (.bat)"
    Write-Host "============================================"
    Write-Host ""

    # ================================================================
    # Syntax Validation
    # ================================================================
    Write-Host "--- Batch Script Syntax ---"

    foreach ($script in @("run_downloader.bat", "youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        if (Test-Path $path) {
            $content = Get-Content $path -Raw
            # Check for @echo off at start
            if ($content -match "@echo off") {
                Write-Pass "$script has @echo off"
                $script:TestsPassed++
            } else {
                Write-Fail "$script missing @echo off"
                $script:TestsFailed++
            }
        } else {
            Write-Fail "$script not found"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # cd /d "%~dp0" (change to script directory)
    # ================================================================
    Write-Host "--- Directory Navigation ---"

    foreach ($script in @("run_downloader.bat", "youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'cd /d "%~dp0"') {
            Write-Pass "$script changes to script directory"
            $script:TestsPassed++
        } else {
            Write-Fail "$script does not cd to script directory"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # yt-dlp existence checks (all download scripts)
    # ================================================================
    Write-Host "--- yt-dlp Installation Check ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'where yt-dlp') {
            Write-Pass "$script checks for yt-dlp"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing yt-dlp check"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # FFmpeg warning + MP3 enforcement (all download scripts)
    # ================================================================
    Write-Host "--- FFmpeg Warning ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'ffmpeg not found') {
            Write-Pass "$script warns about ffmpeg"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing ffmpeg warning"
            $script:TestsFailed++
        }
    }

    # Audio-only modes must refuse to run when ffmpeg is missing.
    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'required for audio extraction') {
            Write-Pass "$script blocks MP3 extraction without ffmpeg"
            $script:TestsPassed++
        } else {
            Write-Fail "$script does not block MP3 extraction without ffmpeg"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # Internet connectivity check (all download scripts)
    # ================================================================
    Write-Host "--- Internet Connectivity Check ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'curl' -and $content -match 'Could not connect') {
            Write-Pass "$script checks internet connectivity with curl"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing connectivity check"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # Empty URL rejection
    # ================================================================
    Write-Host "--- Empty URL Rejection ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'ERROR: No URL entered') {
            Write-Pass "$script has empty URL error message"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing empty URL error"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # Quality Options
    # ================================================================
    Write-Host "--- Quality Options ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match '2160p.*4K' -and $content -match '1440p.*2K' -and $content -match '1080p' -and $content -match '720p' -and $content -match '480p' -and $content -match '360p') {
            Write-Pass "$script has all quality options (1-7)"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing some quality options"
            $script:TestsFailed++
        }
    }

    # Shorts has quality 1-7 (no audio-only option)
    $script:TestsRun++
    $path = Join-Path $ProjectDir "youtube_shorts_download.bat"
    $content = Get-Content $path -Raw
    if ($content -match 'Audio only' -eq $false -and $content -match '360p') {
        Write-Pass "youtube_shorts_download.bat has quality 1-7 (no audio option)"
        $script:TestsPassed++
    } else {
        Write-Fail "youtube_shorts_download.bat quality options mismatch"
        $script:TestsFailed++
    }
    Write-Host ""

    # ================================================================
    # Audio Only Mode
    # ================================================================
    Write-Host "--- Audio Only Mode ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'Audio only.*mp3' -and $content -match 'AUDIOONLY=yes') {
            Write-Pass "$script supports audio-only mode"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing audio-only mode"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # Subtitle Options
    # ================================================================
    Write-Host "--- Subtitle Options ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'No subtitles' -and $content -match 'English' -and $content -match 'Tamil' -and $content -match 'All available') {
            Write-Pass "$script has all subtitle options"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing subtitle options"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # Format String Building
    # ================================================================
    Write-Host "--- Format String Building ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'bestvideo\+bestaudio/best' -and $content -match 'height<=') {
            Write-Pass "$script builds correct format strings"
            $script:TestsPassed++
        } else {
            Write-Fail "$script format string building issue"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # Cookie Support
    # ================================================================
    Write-Host "--- Cookie Support ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'youtube_cookies.txt' -and $content -match 'cookies.txt') {
            Write-Pass "$script has cookie file detection"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing cookie support"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # Output Options (embed-metadata, embed-thumbnail, etc.)
    # ================================================================
    Write-Host "--- Output Options ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'embed-metadata' -and $content -match 'embed-thumbnail' -and $content -match 'no-overwrites') {
            Write-Pass "$script has embed-metadata, embed-thumbnail, no-overwrites"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing output options"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # Retry Logic
    # ================================================================
    Write-Host "--- Retry Logic ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'retries 5' -and $content -match 'fragment-retries 5') {
            Write-Pass "$script has retry logic (retries 5, fragment-retries 5)"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing retry logic"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # Live Stream Filter
    # ================================================================
    Write-Host "--- Live Stream Filter ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'is_live') {
            Write-Pass "$script filters out live streams"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing live stream filter"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # Remote Components Flag
    # ================================================================
    Write-Host "--- Remote Components Flag ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'remote-components ejs:github') {
            Write-Pass "$script has remote-components flag"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing remote-components flag"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # Download Success/Failure Messages
    # ================================================================
    Write-Host "--- Download Status Messages ---"

    # youtube_download.bat
    $script:TestsRun++
    $content = Get-Content (Join-Path $ProjectDir "youtube_download.bat") -Raw
    if ($content -match 'Download COMPLETE' -and $content -match 'Download FAILED') {
        Write-Pass "youtube_download.bat has success and failure messages"
        $script:TestsPassed++
    } else {
        Write-Fail "youtube_download.bat missing status messages"
        $script:TestsFailed++
    }

    # youtube_bulk_download.bat
    $script:TestsRun++
    $content = Get-Content (Join-Path $ProjectDir "youtube_bulk_download.bat") -Raw
    if ($content -match 'All downloads COMPLETE' -and $content -match 'Some downloads may have FAILED') {
        Write-Pass "youtube_bulk_download.bat has bulk status messages"
        $script:TestsPassed++
    } else {
        Write-Fail "youtube_bulk_download.bat missing bulk status messages"
        $script:TestsFailed++
    }

    # youtube_shorts_download.bat
    $script:TestsRun++
    $content = Get-Content (Join-Path $ProjectDir "youtube_shorts_download.bat") -Raw
    if ($content -match 'Download COMPLETE' -and $content -match 'Download FAILED') {
        Write-Pass "youtube_shorts_download.bat has status messages"
        $script:TestsPassed++
    } else {
        Write-Fail "youtube_shorts_download.bat missing status messages"
        $script:TestsFailed++
    }
    Write-Host ""

    # ================================================================
    # run_downloader.bat Menu
    # ================================================================
    Write-Host "--- run_downloader.bat Menu ---"

    $script:TestsRun++
    $content = Get-Content (Join-Path $ProjectDir "run_downloader.bat") -Raw
    if ($content -match 'Single Video Downloader' -and $content -match 'YouTube Shorts Downloader' -and $content -match 'Bulk Downloader' -and $content -match 'Update yt-dlp' -and $content -match 'Exit') {
        Write-Pass "run_downloader.bat has all menu options"
        $script:TestsPassed++
    } else {
        Write-Fail "run_downloader.bat missing menu options"
        $script:TestsFailed++
    }

    $script:TestsRun++
    if ($content -match 'call youtube_download.bat' -and $content -match 'call youtube_shorts_download.bat' -and $content -match 'call youtube_bulk_download.bat') {
        Write-Pass "run_downloader.bat routes to sub-scripts"
        $script:TestsPassed++
    } else {
        Write-Fail "run_downloader.bat missing sub-script routing"
        $script:TestsFailed++
    }

    $script:TestsRun++
    if ($content -match 'Invalid choice') {
        Write-Pass "run_downloader.bat handles invalid input"
        $script:TestsPassed++
    } else {
        Write-Fail "run_downloader.bat missing invalid input handling"
        $script:TestsFailed++
    }
    Write-Host ""

    # ================================================================
    # Batch Update yt-dlp Logic
    # ================================================================
    Write-Host "--- Batch Update yt-dlp ---"

    $script:TestsRun++
    $content = Get-Content (Join-Path $ProjectDir "run_downloader.bat") -Raw
    if ($content -match 'where python' -and $content -match 'pip install' -and $content -match 'yt-dlp -U') {
        Write-Pass "run_downloader.bat has update logic (python -> pip -> yt-dlp -U)"
        $script:TestsPassed++
    } else {
        Write-Fail "run_downloader.bat missing update logic"
        $script:TestsFailed++
    }
    Write-Host ""

    # ================================================================
    # Download Range (bulk and shorts only)
    # ================================================================
    Write-Host "--- Download Range Support ---"

    foreach ($script in @("youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'playlist-items' -and $content -match 'RANGEFLAGS') {
            Write-Pass "$script supports download range"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing download range support"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # Archive Support (bulk and shorts bulk)
    # ================================================================
    Write-Host "--- Download Archive ---"

    foreach ($script in @("youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'download-archive') {
            Write-Pass "$script uses download-archive"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing download-archive"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # Output Naming Patterns
    # ================================================================
    Write-Host "--- Output Naming Patterns ---"

    # youtube_download.bat uses title.150s
    $script:TestsRun++
    $content = Get-Content (Join-Path $ProjectDir "youtube_download.bat") -Raw
    if ($content -match '\(title\)\.150s') {
        Write-Pass "youtube_download.bat uses title.150s naming"
        $script:TestsPassed++
    } else {
        Write-Fail "youtube_download.bat missing title.150s naming"
        $script:TestsFailed++
    }

    # youtube_bulk_download.bat uses playlist_index and playlist
    $script:TestsRun++
    $content = Get-Content (Join-Path $ProjectDir "youtube_bulk_download.bat") -Raw
    if ($content -match 'playlist_index' -and $content -match 'playlist\)s') {
        Write-Pass "youtube_bulk_download.bat uses playlist naming"
        $script:TestsPassed++
    } else {
        Write-Fail "youtube_bulk_download.bat missing playlist naming"
        $script:TestsFailed++
    }

    # youtube_shorts_download.bat - single uses title.150s, bulk uses playlist_index
    $script:TestsRun++
    $content = Get-Content (Join-Path $ProjectDir "youtube_shorts_download.bat") -Raw
    if ($content -match '\(title\)\.150s' -and $content -match 'playlist_index') {
        Write-Pass "youtube_shorts_download.bat has both single and bulk naming"
        $script:TestsPassed++
    } else {
        Write-Fail "youtube_shorts_download.bat naming pattern issue"
        $script:TestsFailed++
    }
    Write-Host ""

    # ================================================================
    # setlocal enabledelayedexpansion
    # ================================================================
    Write-Host "--- Delayed Expansion ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'setlocal enabledelayedexpansion') {
            Write-Pass "$script uses delayed expansion"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing delayed expansion"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # SAVE_DIR Configuration
    # ================================================================
    Write-Host "--- SAVE_DIR Configuration ---"

    foreach ($script in @("youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
        $script:TestsRun++
        $path = Join-Path $ProjectDir $script
        $content = Get-Content $path -Raw
        if ($content -match 'set "SAVE_DIR=' -and $content -match 'downloader\.conf') {
            Write-Pass "$script reads SAVE_DIR from downloader.conf (with a fallback default)"
            $script:TestsPassed++
        } else {
            Write-Fail "$script missing config-driven SAVE_DIR"
            $script:TestsFailed++
        }
    }
    Write-Host ""

    # ================================================================
    # Functional: run youtube_download.bat with a mocked yt-dlp
    # ================================================================
    Write-Host "--- Functional: config-driven SAVE_DIR (executed) ---"

    $binDir = Join-Path $TestTmpDir "bin"
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null
    $logPath = Join-Path $TestTmpDir "ytdlp.log"
    $runDir = Join-Path $TestTmpDir "run"
    New-Item -ItemType Directory -Path $runDir -Force | Out-Null

    # Mock yt-dlp: log its arguments, then fail (so Explorer is not opened).
    $fakeYtdlp = "@echo off`r`nsetlocal DisableDelayedExpansion`r`n(echo %*)>>`"$logPath`"`r`nexit /b 1"
    Set-Content -Path (Join-Path $binDir "yt-dlp.bat") -Value $fakeYtdlp -Encoding ASCII
    Set-Content -Path (Join-Path $binDir "ffmpeg.bat") -Value "@echo off`r`nexit /b 0" -Encoding ASCII

    # Compile tiny curl.exe stubs so the connectivity check stays hermetic
    # (no real network access) and deterministic. A .bat mock cannot be used
    # here because a batch file invoked without CALL does not return control.
    $curlOkExe = Join-Path $TestTmpDir "curl_ok.exe"
    $curlBadExe = Join-Path $TestTmpDir "curl_bad.exe"
    $curlReady = $false
    try {
        Add-Type -TypeDefinition 'public class CurlOkStub { public static int Main(string[] a) { return 0; } }' -OutputAssembly $curlOkExe -OutputType ConsoleApplication -ErrorAction Stop
        Add-Type -TypeDefinition 'public class CurlBadStub { public static int Main(string[] a) { return 1; } }' -OutputAssembly $curlBadExe -OutputType ConsoleApplication -ErrorAction Stop
        $curlReady = $true
    } catch {
        Write-Skip "curl stub exe could not be built: $($_.Exception.Message)"
    }
    function Set-CurlMode {
        param([bool]$Online)
        if (-not $curlReady) { return }
        $src = if ($Online) { $curlOkExe } else { $curlBadExe }
        Copy-Item $src (Join-Path $binDir "curl.exe") -Force
    }
    Set-CurlMode -Online $true

    # Restricted PATH used by the new functional tests: keeps ffmpeg/yt-dlp
    # resolution deterministic (System32 holds `where` + a shadowed curl, but
    # never ffmpeg), so removing a mock really means "not installed".
    $testPath = "$binDir;$env:SystemRoot\System32;$env:SystemRoot"

    Copy-Item (Join-Path $ProjectDir "youtube_download.bat") $runDir -Force
    Set-Content -Path (Join-Path $runDir "downloader.conf") -Value "SAVE_DIR=$TestTmpDir\Movies" -Encoding ASCII
    $inputFile = Join-Path $TestTmpDir "input.txt"
    Set-Content -Path $inputFile -Value "https://youtu.be/abc123`r`n1`r`n1`r`n`r`n" -NoNewline -Encoding ASCII

    $savedPath = $env:Path
    $env:Path = "$binDir;$savedPath"
    try {
        $out = cmd /c "`"$(Join-Path $runDir 'youtube_download.bat')`" < `"$inputFile`"" 2>&1
    } finally {
        $env:Path = $savedPath
    }

    $script:TestsRun++
    if ((Test-Path $logPath) -and ((Get-Content $logPath -Raw) -match [regex]::Escape("$TestTmpDir\Movies"))) {
        Write-Pass "SAVE_DIR from downloader.conf reaches yt-dlp"
        $script:TestsPassed++
    } else {
        Write-Fail "SAVE_DIR from downloader.conf did not reach yt-dlp"
        $script:TestsFailed++
    }

    $script:TestsRun++
    if ((Test-Path $logPath) -and ((Get-Content $logPath -Raw) -match [regex]::Escape("--no-playlist"))) {
        Write-Pass "single video runs with --no-playlist"
        $script:TestsPassed++
    } else {
        Write-Fail "single video did not run with --no-playlist"
        $script:TestsFailed++
    }

    # Invalid URL must be rejected before yt-dlp is called.
    Remove-Item $logPath -ErrorAction SilentlyContinue
    Set-Content -Path $inputFile -Value "not-a-url`r`n`r`n" -NoNewline -Encoding ASCII
    $env:Path = "$binDir;$savedPath"
    try {
        $badOut = cmd /c "`"$(Join-Path $runDir 'youtube_download.bat')`" < `"$inputFile`"" 2>&1
    } finally {
        $env:Path = $savedPath
    }
    $script:TestsRun++
    if (($badOut -match "Invalid URL format") -and (-not (Test-Path $logPath))) {
        Write-Pass "invalid URL is rejected before download"
        $script:TestsPassed++
    } else {
        Write-Fail "invalid URL was not rejected"
        $script:TestsFailed++
    }

    # Online run must NOT emit the offline warning.
    $script:TestsRun++
    if (-not $curlReady) {
        Write-Skip "online run does not warn about connectivity (no curl stub)"
    } elseif ($out -notmatch "Could not connect") {
        Write-Pass "online run does not warn about connectivity"
        $script:TestsPassed++
    } else {
        Write-Fail "online run incorrectly warned about connectivity"
        $script:TestsFailed++
    }

    # Offline: warn, but still proceed to yt-dlp.
    Set-CurlMode -Online $false
    Remove-Item $logPath -ErrorAction SilentlyContinue
    Set-Content -Path $inputFile -Value "https://youtu.be/abc123`r`n1`r`n1`r`n`r`n" -NoNewline -Encoding ASCII
    $env:Path = $testPath
    try {
        $offlineOut = cmd /c "`"$(Join-Path $runDir 'youtube_download.bat')`" < `"$inputFile`"" 2>&1
    } finally {
        $env:Path = $savedPath
    }
    $script:TestsRun++
    if (-not $curlReady) {
        Write-Skip "offline run warns about connectivity (no curl stub)"
    } elseif ($offlineOut -match "Could not connect") {
        Write-Pass "offline run warns about connectivity"
        $script:TestsPassed++
    } else {
        Write-Fail "offline run did not warn about connectivity"
        $script:TestsFailed++
    }
    $script:TestsRun++
    if (Test-Path $logPath) {
        Write-Pass "offline warning does not abort the download"
        $script:TestsPassed++
    } else {
        Write-Fail "offline warning aborted the download"
        $script:TestsFailed++
    }

    # Audio-only (mp3) without ffmpeg: error out and never call yt-dlp.
    Set-CurlMode -Online $true
    Remove-Item (Join-Path $binDir "ffmpeg.bat") -ErrorAction SilentlyContinue
    Remove-Item $logPath -ErrorAction SilentlyContinue
    Set-Content -Path $inputFile -Value "https://youtu.be/abc123`r`n8`r`n`r`n" -NoNewline -Encoding ASCII
    $env:Path = $testPath
    try {
        $audioOut = cmd /c "`"$(Join-Path $runDir 'youtube_download.bat')`" < `"$inputFile`"" 2>&1
    } finally {
        $env:Path = $savedPath
    }
    $script:TestsRun++
    if ($audioOut -match "required for audio extraction") {
        Write-Pass "MP3 mode without ffmpeg shows an error"
        $script:TestsPassed++
    } else {
        Write-Fail "MP3 mode without ffmpeg did not show an error"
        $script:TestsFailed++
    }
    $script:TestsRun++
    if (-not (Test-Path $logPath)) {
        Write-Pass "MP3 mode without ffmpeg does not call yt-dlp"
        $script:TestsPassed++
    } else {
        Write-Fail "MP3 mode without ffmpeg still called yt-dlp"
        $script:TestsFailed++
    }
    # Restore the ffmpeg mock.
    Set-Content -Path (Join-Path $binDir "ffmpeg.bat") -Value "@echo off`r`nexit /b 0" -Encoding ASCII
    Write-Host ""

} finally {
    # Cleanup
    Remove-Item -Path $TestTmpDir -Recurse -Force -ErrorAction SilentlyContinue

    $failed = Print-Summary
    if ($failed -gt 0) { exit 1 }
}
