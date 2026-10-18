# PowerShell test runner for yt-downloader batch scripts
# Run with: pwsh -ExecutionPolicy Bypass -File run_all_tests.ps1

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

$script:TestsRun = 0
$script:TestsPassed = 0
$script:TestsFailed = 0

function Write-TestResult {
    param(
        [string]$Label,
        [bool]$Passed,
        [string]$Details = ""
    )
    $script:TestsRun++
    if ($Passed) {
        Write-Host "  PASS: $Label" -ForegroundColor Green
        $script:TestsPassed++
    } else {
        Write-Host "  FAIL: $Label" -ForegroundColor Red
        if ($Details) { Write-Host "    $Details" -ForegroundColor Gray }
        $script:TestsFailed++
    }
}

function Test-FileContent {
    param(
        [string]$FilePath,
        [string]$Pattern,
        [string]$Label,
        [bool]$ShouldMatch = $true
    )
    $content = Get-Content $FilePath -Raw
    $found = $content -match $Pattern
    if ($ShouldMatch) {
        Write-TestResult -Label $Label -Passed $found -Details "Pattern '$Pattern' not found"
    } else {
        Write-TestResult -Label $Label -Passed (-not $found) -Details "Pattern '$Pattern' was found but should not be"
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  yt-downloader Batch Script Test Suite" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ── Syntax Check ─────────────────────────────────────
Write-Host "--- Batch File Syntax Validation ---" -ForegroundColor Yellow
$batFiles = @(
    "youtube_download.bat",
    "youtube_bulk_download.bat",
    "youtube_shorts_download.bat",
    "run_downloader.bat"
)
foreach ($file in $batFiles) {
    $path = Join-Path $ProjectDir $file
    $exists = Test-Path $path
    Write-TestResult -Label "$file exists" -Passed $exists
    if ($exists) {
        $content = Get-Content $path -Raw
        $hasEchoOff = $content -match "@echo off"
        Write-TestResult -Label "$file has @echo off" -Passed $hasEchoOff
        if ($file -ne "run_downloader.bat") {
            $hasEndLocal = $content -match "endlocal|setlocal"
            Write-TestResult -Label "$file uses setlocal/endlocal" -Passed $hasEndLocal
        }
    }
}
Write-Host ""

# ── youtube_download.bat Tests ────────────────────────
Write-Host "--- youtube_download.bat Tests ---" -ForegroundColor Yellow
$dlBat = Join-Path $ProjectDir "youtube_download.bat"

Test-FileContent -FilePath $dlBat -Pattern "where yt-dlp" -Label "checks for yt-dlp installation"
Test-FileContent -FilePath $dlBat -Pattern "where ffmpeg" -Label "checks for ffmpeg"
Test-FileContent -FilePath $dlBat -Pattern "color 0B" -Label "sets console color"
Test-FileContent -FilePath $dlBat -Pattern "YouTube Video Downloader" -Label "sets window title"
Test-FileContent -FilePath $dlBat -Pattern "set /p.*URL" -Label "prompts for URL"
Test-FileContent -FilePath $dlBat -Pattern 'if "%URL%"==""' -Label "validates empty URL"
Test-FileContent -FilePath $dlBat -Pattern "exit /b 1" -Label "exits with code 1 on error"
Test-FileContent -FilePath $dlBat -Pattern "mkdir" -Label "creates save directory"
Test-FileContent -FilePath $dlBat -Pattern "Quality options" -Label "shows quality menu"
Test-FileContent -FilePath $dlBat -Pattern "FHEIGHT=2160" -Label "quality 2 maps to 2160p"
Test-FileContent -FilePath $dlBat -Pattern "FHEIGHT=1080" -Label "quality 4 maps to 1080p"
Test-FileContent -FilePath $dlBat -Pattern "FHEIGHT=best" -Label "quality 1 maps to best"
Test-FileContent -FilePath $dlBat -Pattern "AUDIOONLY=yes" -Label "quality 8 sets audio only"
Test-FileContent -FilePath $dlBat -Pattern "audio-format mp3" -Label "audio only uses mp3"
Test-FileContent -FilePath $dlBat -Pattern "Subtitle options" -Label "shows subtitle menu"
Test-FileContent -FilePath $dlBat -Pattern "SUBLANG=en" -Label "subtitle option 2 = English"
Test-FileContent -FilePath $dlBat -Pattern "SUBLANG=ta" -Label "subtitle option 3 = Tamil"
Test-FileContent -FilePath $dlBat -Pattern "SUBLANG=all" -Label "subtitle option 4 = All"
Test-FileContent -FilePath $dlBat -Pattern "youtube_cookies.txt" -Label "checks for user cookies"
Test-FileContent -FilePath $dlBat -Pattern "cookies.txt" -Label "checks for local cookies"
Test-FileContent -FilePath $dlBat -Pattern "embed-metadata" -Label "embeds metadata"
Test-FileContent -FilePath $dlBat -Pattern "embed-thumbnail" -Label "embeds thumbnail"
Test-FileContent -FilePath $dlBat -Pattern "merge-output-format mp4" -Label "merges to mp4"
Test-FileContent -FilePath $dlBat -Pattern "retries 5" -Label "has retry logic"
Test-FileContent -FilePath $dlBat -Pattern "fragment-retries 5" -Label "has fragment retry logic"
Test-FileContent -FilePath $dlBat -Pattern "no-overwrites" -Label "skips existing files"
Test-FileContent -FilePath $dlBat -Pattern "is_live" -Label "skips live streams"
Test-FileContent -FilePath $dlBat -Pattern "Download COMPLETE" -Label "shows success message"
Test-FileContent -FilePath $dlBat -Pattern "Download FAILED" -Label "shows failure message"
Test-FileContent -FilePath $dlBat -Pattern "explorer" -Label "opens folder on completion"
Test-FileContent -FilePath $dlBat -Pattern "bestvideo\+bestaudio" -Label "best quality format string"
Test-FileContent -FilePath $dlBat -Pattern "height<=" -Label "quality-specific format string"
Test-FileContent -FilePath $dlBat -Pattern "remote-components ejs:github" -Label "uses remote components"
Write-Host ""

# ── youtube_bulk_download.bat Tests ───────────────────
Write-Host "--- youtube_bulk_download.bat Tests ---" -ForegroundColor Yellow
$bulkBat = Join-Path $ProjectDir "youtube_bulk_download.bat"

Test-FileContent -FilePath $bulkBat -Pattern "where yt-dlp" -Label "checks for yt-dlp installation"
Test-FileContent -FilePath $bulkBat -Pattern "where ffmpeg" -Label "checks for ffmpeg"
Test-FileContent -FilePath $bulkBat -Pattern "YouTube Bulk Downloader" -Label "sets window title"
Test-FileContent -FilePath $bulkBat -Pattern "Playlist.*Channel" -Label "shows playlist/channel info"
Test-FileContent -FilePath $bulkBat -Pattern "set /p.*URL" -Label "prompts for URL"
Test-FileContent -FilePath $bulkBat -Pattern 'if "%URL%"==""' -Label "validates empty URL"
Test-FileContent -FilePath $bulkBat -Pattern "Quality options" -Label "shows quality menu"
Test-FileContent -FilePath $bulkBat -Pattern "AUDIOONLY=yes" -Label "quality 8 sets audio only"
Test-FileContent -FilePath $bulkBat -Pattern "Subtitle options" -Label "shows subtitle menu"
Test-FileContent -FilePath $bulkBat -Pattern "playlist-items" -Label "supports playlist range"
Test-FileContent -FilePath $bulkBat -Pattern "yes-playlist" -Label "uses yes-playlist flag"
Test-FileContent -FilePath $bulkBat -Pattern "download-archive" -Label "uses download archive"
Test-FileContent -FilePath $bulkBat -Pattern "playlist_index" -Label "output uses playlist index"
Test-FileContent -FilePath $bulkBat -Pattern "playlist[)]s" -Label "output uses playlist name in path"
Test-FileContent -FilePath $bulkBat -Pattern "youtube_cookies.txt" -Label "checks for user cookies"
Test-FileContent -FilePath $bulkBat -Pattern "cookies.txt" -Label "checks for local cookies"
Test-FileContent -FilePath $bulkBat -Pattern "embed-metadata" -Label "embeds metadata"
Test-FileContent -FilePath $bulkBat -Pattern "embed-thumbnail" -Label "embeds thumbnail"
Test-FileContent -FilePath $bulkBat -Pattern "merge-output-format mp4" -Label "merges to mp4"
Test-FileContent -FilePath $bulkBat -Pattern "retries 5" -Label "has retry logic"
Test-FileContent -FilePath $bulkBat -Pattern "no-overwrites" -Label "skips existing files"
Test-FileContent -FilePath $bulkBat -Pattern "is_live" -Label "skips live streams"
Test-FileContent -FilePath $bulkBat -Pattern "All downloads COMPLETE" -Label "shows success message"
Test-FileContent -FilePath $bulkBat -Pattern "Some downloads may have FAILED" -Label "shows failure message"
Test-FileContent -FilePath $bulkBat -Pattern "remote-components ejs:github" -Label "uses remote components"
Write-Host ""

# ── youtube_shorts_download.bat Tests ─────────────────
Write-Host "--- youtube_shorts_download.bat Tests ---" -ForegroundColor Yellow
$shortsBat = Join-Path $ProjectDir "youtube_shorts_download.bat"

Test-FileContent -FilePath $shortsBat -Pattern "where yt-dlp" -Label "checks for yt-dlp installation"
Test-FileContent -FilePath $shortsBat -Pattern "where ffmpeg" -Label "checks for ffmpeg"
Test-FileContent -FilePath $shortsBat -Pattern "YouTube Shorts Downloader" -Label "sets window title"
Test-FileContent -FilePath $shortsBat -Pattern "shorts/" -Label "shows shorts URL example"
Test-FileContent -FilePath $shortsBat -Pattern "set /p.*URL" -Label "prompts for URL"
Test-FileContent -FilePath $shortsBat -Pattern 'if "%URL%"==""' -Label "validates empty URL"
Test-FileContent -FilePath $shortsBat -Pattern "Download type" -Label "asks for download type"
Test-FileContent -FilePath $shortsBat -Pattern "Single Short" -Label "shows single short option"
Test-FileContent -FilePath $shortsBat -Pattern "All Shorts from a channel" -Label "shows bulk option"
Test-FileContent -FilePath $shortsBat -Pattern "BULK=yes" -Label "bulk mode flag"
Test-FileContent -FilePath $shortsBat -Pattern "BULK=no" -Label "single mode flag"
Test-FileContent -FilePath $shortsBat -Pattern "playlist-items" -Label "bulk supports range"
Test-FileContent -FilePath $shortsBat -Pattern "yes-playlist" -Label "bulk uses yes-playlist"
Test-FileContent -FilePath $shortsBat -Pattern "download-archive" -Label "bulk uses archive"
Test-FileContent -FilePath $shortsBat -Pattern "playlist_index" -Label "bulk output uses playlist index"
Test-FileContent -FilePath $shortsBat -Pattern "Quality options" -Label "shows quality menu"
Test-FileContent -FilePath $shortsBat -Pattern "youtube_cookies.txt" -Label "checks for user cookies"
Test-FileContent -FilePath $shortsBat -Pattern "cookies.txt" -Label "checks for local cookies"
Test-FileContent -FilePath $shortsBat -Pattern "embed-metadata" -Label "embeds metadata"
Test-FileContent -FilePath $shortsBat -Pattern "embed-thumbnail" -Label "embeds thumbnail"
Test-FileContent -FilePath $shortsBat -Pattern "merge-output-format mp4" -Label "merges to mp4"
Test-FileContent -FilePath $shortsBat -Pattern "retries 5" -Label "has retry logic"
Test-FileContent -FilePath $shortsBat -Pattern "no-overwrites" -Label "skips existing files"
Test-FileContent -FilePath $shortsBat -Pattern "Download COMPLETE" -Label "shows success message"
Test-FileContent -FilePath $shortsBat -Pattern "Download FAILED" -Label "shows failure message"
Test-FileContent -FilePath $shortsBat -Pattern "remote-components ejs:github" -Label "uses remote components"
Write-Host ""

# ── run_downloader.bat Tests ──────────────────────────
Write-Host "--- run_downloader.bat Tests ---" -ForegroundColor Yellow
$runBat = Join-Path $ProjectDir "run_downloader.bat"

Test-FileContent -FilePath $runBat -Pattern "@echo off" -Label "has @echo off"
Test-FileContent -FilePath $runBat -Pattern "YouTube Downloader Suite" -Label "sets window title"
Test-FileContent -FilePath $runBat -Pattern "Single Video Downloader" -Label "shows option 1"
Test-FileContent -FilePath $runBat -Pattern "YouTube Shorts Downloader" -Label "shows option 2"
Test-FileContent -FilePath $runBat -Pattern "Bulk Downloader" -Label "shows option 3"
Test-FileContent -FilePath $runBat -Pattern "Update yt-dlp" -Label "shows option 4"
Test-FileContent -FilePath $runBat -Pattern "Exit" -Label "shows exit option"
Test-FileContent -FilePath $runBat -Pattern "call youtube_download.bat" -Label "option 1 calls download"
Test-FileContent -FilePath $runBat -Pattern "call youtube_shorts_download.bat" -Label "option 2 calls shorts"
Test-FileContent -FilePath $runBat -Pattern "call youtube_bulk_download.bat" -Label "option 3 calls bulk"
Test-FileContent -FilePath $runBat -Pattern "pip.*install.*yt-dlp" -Label "option 4 tries pip update"
Test-FileContent -FilePath $runBat -Pattern "yt-dlp -U" -Label "option 4 tries self-update"
Test-FileContent -FilePath $runBat -Pattern "Invalid choice" -Label "handles invalid input"
Test-FileContent -FilePath $runBat -Pattern "goto menu" -Label "loops back to menu"
Test-FileContent -FilePath $runBat -Pattern 'cd /d "%~dp0"' -Label "changes to script directory"
Write-Host ""

# ── Configuration & Input Validation ──────────────────
Write-Host "--- Configuration & Input Validation ---" -ForegroundColor Yellow
foreach ($file in @("youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
    $p = Join-Path $ProjectDir $file
    Test-FileContent -FilePath $p -Pattern "downloader[.]conf" -Label "$file reads downloader.conf"
    Test-FileContent -FilePath $p -Pattern "Invalid URL format" -Label "$file validates the URL format"
    Test-FileContent -FilePath $p -Pattern "js-runtimes" -Label "$file enables a JS runtime when needed"
    Test-FileContent -FilePath $p -Pattern "Failed to create save directory" -Label "$file checks the save directory"
}
foreach ($file in @("youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
    $p = Join-Path $ProjectDir $file
    Test-FileContent -FilePath $p -Pattern "Invalid range format" -Label "$file validates the download range"
}
Test-FileContent -FilePath $dlBat -Pattern "no-playlist" -Label "single video uses --no-playlist"
Test-FileContent -FilePath $shortsBat -Pattern "no-playlist" -Label "single short uses --no-playlist"
Write-TestResult -Label "downloader.conf.example exists" -Passed (Test-Path (Join-Path $ProjectDir "downloader.conf.example"))
Write-Host ""

# ── Connectivity & FFmpeg Parity ──────────────────────
Write-Host "--- Connectivity & FFmpeg Parity ---" -ForegroundColor Yellow
foreach ($file in @("youtube_download.bat", "youtube_bulk_download.bat", "youtube_shorts_download.bat")) {
    $p = Join-Path $ProjectDir $file
    Test-FileContent -FilePath $p -Pattern "curl" -Label "$file checks internet connectivity"
    Test-FileContent -FilePath $p -Pattern "Could not connect" -Label "$file warns when offline"
}
foreach ($file in @("youtube_download.bat", "youtube_bulk_download.bat")) {
    $p = Join-Path $ProjectDir $file
    Test-FileContent -FilePath $p -Pattern "required for audio extraction" -Label "$file blocks MP3 extraction without ffmpeg"
}
Write-Host ""

# ── Summary ──────────────────────────────────────────
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Batch Script Tests Complete" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Tests run: $($script:TestsRun)"
Write-Host " Passed: $($script:TestsPassed)" -ForegroundColor Green
if ($script:TestsFailed -gt 0) {
    Write-Host " Failed: $($script:TestsFailed)" -ForegroundColor Red
} else {
    Write-Host " Failed: $($script:TestsFailed)"
}
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

exit $script:TestsFailed
