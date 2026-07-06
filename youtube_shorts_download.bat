@echo off
setlocal enabledelayedexpansion
title YouTube Shorts Downloader
color 0E
cd /d "%~dp0"

:: Check that yt-dlp exists
where yt-dlp >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: yt-dlp is not installed.
    echo Please run option 4 from the main menu first.
    pause
    exit /b 1
)

:: Check FFmpeg
where ffmpeg >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: ffmpeg not found. Some videos may not merge correctly.
)

:: ============================================
:: HARDCODE YOUR SAVE LOCATION HERE
:: Example: set "SAVE_DIR=D:\YouTube Shorts"
:: Leave blank to be asked every time
:: ============================================
set "SAVE_DIR=D:\5 System 6\Videos"

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
    exit /b 1
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
    if "!RANGE!"=="" (
        set "RANGEFLAGS="
    ) else (
        set "RANGEFLAGS=--playlist-items !RANGE!"
    )
) else (
    set "RANGEFLAGS="
)

:: Quality
echo.
echo Quality options:
echo   1. Best (default)
echo   2. 2160p (4K)
echo   3. 1440p (2K)
echo   4. 1080p
echo   5. 720p
echo   6. 480p
echo   7. 360p
echo.
set /p "QCHOICE=Choose quality (1-7, default=1): "

if "%QCHOICE%"=="2" (
    set "FHEIGHT=2160"
) else if "%QCHOICE%"=="3" (
    set "FHEIGHT=1440"
) else if "%QCHOICE%"=="4" (
    set "FHEIGHT=1080"
) else if "%QCHOICE%"=="5" (
    set "FHEIGHT=720"
) else if "%QCHOICE%"=="6" (
    set "FHEIGHT=480"
) else if "%QCHOICE%"=="7" (
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

:: Cookies support
set "COOKIEFLAGS="
if exist "%USERPROFILE%\youtube_cookies.txt" (
    set COOKIEFLAGS=--cookies "%USERPROFILE%\youtube_cookies.txt"
) else if exist "cookies.txt" (
    set COOKIEFLAGS=--cookies "cookies.txt"
)

:: Single short
if "%BULK%"=="no" (
    if defined COOKIEFLAGS (
        yt-dlp --remote-components ejs:github !COOKIEFLAGS! -f "%FMTSTR%" --merge-output-format mp4 --embed-metadata --embed-thumbnail --retries 5 --fragment-retries 5 -c --part --no-overwrites -o "%SAVE_DIR%\%%(title).150s.%%(ext)s" "%URL%"
    ) else (
        yt-dlp --remote-components ejs:github -f "%FMTSTR%" --merge-output-format mp4 --embed-metadata --embed-thumbnail --retries 5 --fragment-retries 5 -c --part --no-overwrites -o "%SAVE_DIR%\%%(title).150s.%%(ext)s" "%URL%"
    )
    goto done
)

:: Bulk shorts from channel
if defined COOKIEFLAGS (
    if defined RANGEFLAGS (
        yt-dlp --remote-components ejs:github !COOKIEFLAGS! --yes-playlist -f "%FMTSTR%" !RANGEFLAGS! --merge-output-format mp4 --embed-metadata --embed-thumbnail --retries 5 --fragment-retries 5 -c --part --no-overwrites --download-archive "%~dp0archive.txt" -o "%SAVE_DIR%\%%(playlist_index)s - %%(title).150s.%%(ext)s" "%URL%"
    ) else (
        yt-dlp --remote-components ejs:github !COOKIEFLAGS! --yes-playlist -f "%FMTSTR%" --merge-output-format mp4 --embed-metadata --embed-thumbnail --retries 5 --fragment-retries 5 -c --part --no-overwrites --download-archive "%~dp0archive.txt" -o "%SAVE_DIR%\%%(playlist_index)s - %%(title).150s.%%(ext)s" "%URL%"
    )
) else (
    if defined RANGEFLAGS (
        yt-dlp --remote-components ejs:github --yes-playlist -f "%FMTSTR%" !RANGEFLAGS! --merge-output-format mp4 --embed-metadata --embed-thumbnail --retries 5 --fragment-retries 5 -c --part --no-overwrites --download-archive "%~dp0archive.txt" -o "%SAVE_DIR%\%%(playlist_index)s - %%(title).150s.%%(ext)s" "%URL%"
    ) else (
        yt-dlp --remote-components ejs:github --yes-playlist -f "%FMTSTR%" --merge-output-format mp4 --embed-metadata --embed-thumbnail --retries 5 --fragment-retries 5 -c --part --no-overwrites --download-archive "%~dp0archive.txt" -o "%SAVE_DIR%\%%(playlist_index)s - %%(title).150s.%%(ext)s" "%URL%"
    )
)

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
    explorer "%SAVE_DIR%"
)

echo.
pause
