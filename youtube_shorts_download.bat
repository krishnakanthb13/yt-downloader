@echo off
title YouTube Shorts Downloader
color 0E
cd /d "%~dp0"

:: ============================================
:: HARDCODE YOUR SAVE LOCATION HERE
:: Example: set "SAVE_DIR=D:\YouTube Shorts"
:: Leave blank to be asked every time
:: ============================================
set "SAVE_DIR=D:\5 System 6\Vidoes"

:: ============================================

echo ============================================
echo       YOUTUBE SHORTS DOWNLOADER
echo ============================================
echo.

:: Ask for URL
echo Paste a single Short URL or a channel's Shorts page URL.
echo.
echo Single Short  : https://www.youtube.com/shorts/XXXXXXXXXXX
echo Channel Shorts: https://www.youtube.com/@ChannelName/shorts
echo.
set /p "URL=Paste URL here: "

if "%URL%"=="" (
    echo ERROR: No URL entered.
    pause
    exit /b
)

:: Save location
if "%SAVE_DIR%"=="" (
    echo.
    set /p "SAVE_DIR=Output folder (leave blank for 'Shorts'): "
    if "%SAVE_DIR%"=="" set "SAVE_DIR=Shorts"
)

if not exist "%SAVE_DIR%" mkdir "%SAVE_DIR%"
echo Save location: %SAVE_DIR%

:: Detect if bulk or single
echo.
echo Download type:
echo   1. Single Short (default)
echo   2. All Shorts from a channel page
echo.
set /p "DTYPE=Choose type (1-2, default=1): "

if "%DTYPE%"=="2" (
    set "BULK=yes"
) else (
    set "BULK=no"
)

:: Download range only for bulk
if "%BULK%"=="yes" (
    echo.
    echo Download range (useful for large channels^):
    echo   Leave blank to download ALL shorts
    echo   Example: enter  1-20  to download first 20 shorts
    echo.
    set /p "RANGE=Enter range (or leave blank for all): "
    if "%RANGE%"=="" (
        set "RANGEFLAGS="
    ) else (
        set "RANGEFLAGS=--playlist-items %RANGE%"
    )
) else (
    set "RANGEFLAGS="
)

:: Quality
echo.
echo Quality options:
echo   1. Best (default)
echo   2. 720p
echo   3. 480p
echo   4. 360p
echo.
set /p "QCHOICE=Choose quality (1-4, default=1): "

if "%QCHOICE%"=="2" (
    set "FHEIGHT=720"
) else if "%QCHOICE%"=="3" (
    set "FHEIGHT=480"
) else if "%QCHOICE%"=="4" (
    set "FHEIGHT=360"
) else (
    set "FHEIGHT=best"
)

echo.
echo ============================================
echo  Downloading...
echo  URL    : %URL%
echo  Output : %SAVE_DIR%
echo  Quality: %FHEIGHT%
echo  Bulk   : %BULK%
echo ============================================
echo.

:: Build format string
if "%FHEIGHT%"=="best" (
    set "FMTSTR=bestvideo+bestaudio/best"
) else (
    set "FMTSTR=bestvideo[height<=%FHEIGHT%]+bestaudio/best[height<=%FHEIGHT%]"
)

:: Single short
if "%BULK%"=="no" (
    yt-dlp ^
        -f "%FMTSTR%" ^
        --merge-output-format mp4 ^
        --retries 5 ^
        --fragment-retries 5 ^
        --continue ^
        --no-overwrites ^
        -o "%SAVE_DIR%\%%(title)s.%%(ext)s" ^
        "%URL%"
    goto done
)

:: Bulk shorts from channel
yt-dlp ^
    --yes-playlist ^
    -f "%FMTSTR%" ^
    %RANGEFLAGS% ^
    --merge-output-format mp4 ^
    --retries 5 ^
    --fragment-retries 5 ^
    --continue ^
    --no-overwrites ^
    -o "%SAVE_DIR%\%%(playlist_index)s - %%(title)s.%%(ext)s" ^
    "%URL%"

:done
echo.
if errorlevel 1 (
    echo ============================================
    echo  Download FAILED. Check errors above.
    echo ============================================
) else (
    echo ============================================
    echo  Download COMPLETE!
    echo  Files saved in: %SAVE_DIR%
    echo ============================================
)

echo.
pause
