@echo off
title YouTube Video Downloader
color 0B
cd /d "%~dp0"

:: ============================================
:: HARDCODE YOUR SAVE LOCATION HERE
:: Example: set "SAVE_DIR=D:\YouTube Downloads"
:: Leave blank to be asked every time
:: ============================================
set "SAVE_DIR=D:\5 System 6\Vidoes"

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
    exit /b
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
echo   2. 1080p
echo   3. 720p
echo   4. 480p
echo   5. 360p
echo   6. Audio only (mp3)
echo.
set /p "QCHOICE=Choose quality (1-6, default=1): "

if "%QCHOICE%"=="2" (
    set "FHEIGHT=1080"
    set "AUDIOONLY=no"
) else if "%QCHOICE%"=="3" (
    set "FHEIGHT=720"
    set "AUDIOONLY=no"
) else if "%QCHOICE%"=="4" (
    set "FHEIGHT=480"
    set "AUDIOONLY=no"
) else if "%QCHOICE%"=="5" (
    set "FHEIGHT=360"
    set "AUDIOONLY=no"
) else if "%QCHOICE%"=="6" (
    set "FHEIGHT=best"
    set "AUDIOONLY=yes"
) else (
    set "FHEIGHT=best"
    set "AUDIOONLY=no"
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
echo  URL     : %URL%
echo  Output  : %SAVE_DIR%
echo  Quality : %FHEIGHT%
echo ============================================
echo.

:: Audio only
if "%AUDIOONLY%"=="yes" (
    yt-dlp ^
        --remote-components ejs:github ^
        -x --audio-format mp3 --audio-quality 0 ^
        --retries 5 ^
        --fragment-retries 5 ^
        --continue ^
        --no-overwrites ^
        -o "%SAVE_DIR%\%%(title)s.%%(ext)s" ^
        "%URL%"
    goto done
)

:: Build format string
if "%FHEIGHT%"=="best" (
    set "FMTSTR=bestvideo+bestaudio/best"
) else (
    set "FMTSTR=bestvideo[height<=%FHEIGHT%]+bestaudio/best[height<=%FHEIGHT%]"
)

:: Build subtitle flags
if "%SUBLANG%"=="none" (
    set "SUBFLAGS="
) else if "%SUBLANG%"=="all" (
    set "SUBFLAGS=--write-subs --write-auto-subs --sub-langs all"
) else (
    set "SUBFLAGS=--write-subs --write-auto-subs --sub-langs %SUBLANG%"
)

yt-dlp ^
    --remote-components ejs:github ^
    -f "%FMTSTR%" ^
    %SUBFLAGS% ^
    --merge-output-format mp4 ^
    --retries 5 ^
    --fragment-retries 5 ^
    --continue ^
    --no-overwrites ^
    -o "%SAVE_DIR%\%%(title)s.%%(ext)s" ^
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
    echo  File saved in: %SAVE_DIR%
    echo ============================================
    explorer "%SAVE_DIR%"
)

echo.
pause
