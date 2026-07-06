@echo off
setlocal enabledelayedexpansion
title YouTube Video Downloader
color 0B
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
:: Example: set "SAVE_DIR=D:\YouTube Downloads"
:: Leave blank to be asked every time
:: ============================================
set "SAVE_DIR=D:\5 System 6\Videos"

:: ============================================

echo ============================================
echo         YOUTUBE VIDEO DOWNLOADER
echo ============================================
echo.

:: Ask for URL
echo Paste the YouTube video URL.
echo Example: https://www.youtube.com/watch?v=XXXXXXXXXXX
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
    set /p "SAVE_DIR=Output folder (leave blank for 'Downloads'): "
    if "%SAVE_DIR%"=="" set "SAVE_DIR=Downloads"
)

if not exist "%SAVE_DIR%" mkdir "%SAVE_DIR%"
echo Save location: %SAVE_DIR%

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
echo   8. Audio only (mp3)
echo.
set /p "QCHOICE=Choose quality (1-8, default=1): "

set "AUDIOONLY=no"
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
) else if "%QCHOICE%"=="8" (
    set "FHEIGHT=best"
    set "AUDIOONLY=yes"
) else (
    set "FHEIGHT=best"
)

:: Subtitles (skip if audio only)
if "%AUDIOONLY%"=="no" (
    echo.
    echo Subtitle options:
    echo   1. No subtitles (default^)
    echo   2. English
    echo   3. Tamil
    echo   4. All available
    echo.
    set /p "SCHOICE=Download subtitles? (1-4, default=1): "

    if "!SCHOICE!"=="2" (
        set "SUBLANG=en"
    ) else if "!SCHOICE!"=="3" (
        set "SUBLANG=ta"
    ) else if "!SCHOICE!"=="4" (
        set "SUBLANG=all"
    ) else (
        set "SUBLANG=none"
    )
) else (
    set "SUBLANG=none"
)

echo.
echo ============================================
echo  Downloading...
echo  URL     : !URL!
echo  Output  : %SAVE_DIR%
echo  Quality : %FHEIGHT%
echo ============================================
echo.

:: Cookies support
set "COOKIEFLAGS="
if exist "%USERPROFILE%\youtube_cookies.txt" (
    set COOKIEFLAGS=--cookies "%USERPROFILE%\youtube_cookies.txt"
) else if exist "cookies.txt" (
    set COOKIEFLAGS=--cookies "cookies.txt"
)

set "FILTER=^!is_live"

:: Build format string
if "%FHEIGHT%"=="best" (
    set "FMTSTR=bestvideo+bestaudio/best"
) else (
    set "FMTSTR=bestvideo[height<=%FHEIGHT%]+bestaudio/best[height<=%FHEIGHT%]"
)

:: Run yt-dlp based on options
if "%AUDIOONLY%"=="yes" (
    if defined COOKIEFLAGS (
        yt-dlp --remote-components ejs:github !COOKIEFLAGS! -x --audio-format mp3 --audio-quality 0 --retries 5 --fragment-retries 5 -c --part --no-overwrites --match-filter "!FILTER!" -o "%SAVE_DIR%\%%(title).150s.%%(ext)s" "%URL%"
    ) else (
        yt-dlp --remote-components ejs:github -x --audio-format mp3 --audio-quality 0 --retries 5 --fragment-retries 5 -c --part --no-overwrites --match-filter "!FILTER!" -o "%SAVE_DIR%\%%(title).150s.%%(ext)s" "%URL%"
    )
) else (
    if defined COOKIEFLAGS (
        if "%SUBLANG%"=="none" (
            yt-dlp --remote-components ejs:github !COOKIEFLAGS! -f "%FMTSTR%" --merge-output-format mp4 --embed-metadata --embed-thumbnail --retries 5 --fragment-retries 5 -c --part --no-overwrites --match-filter "!FILTER!" -o "%SAVE_DIR%\%%(title).150s.%%(ext)s" "%URL%"
        ) else if "%SUBLANG%"=="all" (
            yt-dlp --remote-components ejs:github !COOKIEFLAGS! -f "%FMTSTR%" --write-subs --write-auto-subs --sub-langs all --merge-output-format mp4 --embed-metadata --embed-thumbnail --retries 5 --fragment-retries 5 -c --part --no-overwrites --match-filter "!FILTER!" -o "%SAVE_DIR%\%%(title).150s.%%(ext)s" "%URL%"
        ) else (
            yt-dlp --remote-components ejs:github !COOKIEFLAGS! -f "%FMTSTR%" --write-subs --write-auto-subs --sub-langs %SUBLANG% --merge-output-format mp4 --embed-metadata --embed-thumbnail --retries 5 --fragment-retries 5 -c --part --no-overwrites --match-filter "!FILTER!" -o "%SAVE_DIR%\%%(title).150s.%%(ext)s" "%URL%"
        )
    ) else (
        if "%SUBLANG%"=="none" (
            yt-dlp --remote-components ejs:github -f "%FMTSTR%" --merge-output-format mp4 --embed-metadata --embed-thumbnail --retries 5 --fragment-retries 5 -c --part --no-overwrites --match-filter "!FILTER!" -o "%SAVE_DIR%\%%(title).150s.%%(ext)s" "%URL%"
        ) else if "%SUBLANG%"=="all" (
            yt-dlp --remote-components ejs:github -f "%FMTSTR%" --write-subs --write-auto-subs --sub-langs all --merge-output-format mp4 --embed-metadata --embed-thumbnail --retries 5 --fragment-retries 5 -c --part --no-overwrites --match-filter "!FILTER!" -o "%SAVE_DIR%\%%(title).150s.%%(ext)s" "%URL%"
        ) else (
            yt-dlp --remote-components ejs:github -f "%FMTSTR%" --write-subs --write-auto-subs --sub-langs %SUBLANG% --merge-output-format mp4 --embed-metadata --embed-thumbnail --retries 5 --fragment-retries 5 -c --part --no-overwrites --match-filter "!FILTER!" -o "%SAVE_DIR%\%%(title).150s.%%(ext)s" "%URL%"
        )
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
    echo  File saved in: %SAVE_DIR%
    echo ============================================
    explorer "%SAVE_DIR%"
)

echo.
pause
