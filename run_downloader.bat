@echo off
title YouTube Downloader Suite - Master Menu
color 0A
cd /d "%~dp0"

:menu
cls
echo ============================================
echo         YOUTUBE DOWNLOADER SUITE
echo ============================================
echo.
echo Choose a downloader option:
echo   1. Single Video Downloader
echo   2. YouTube Shorts Downloader
echo   3. Bulk Downloader (Playlists/Channels)
echo   4. Update yt-dlp
echo   0. Exit
echo.
set /p "MCHOICE=Enter choice (0-4): "

if "%MCHOICE%"=="1" (
    cls
    call youtube_download.bat
    goto menu
) else if "%MCHOICE%"=="2" (
    cls
    call youtube_shorts_download.bat
    goto menu
) else if "%MCHOICE%"=="3" (
    cls
    call youtube_bulk_download.bat
    goto menu
) else if "%MCHOICE%"=="4" (
    cls
    echo ============================================
    echo  Updating yt-dlp...
    echo ============================================
    python -m pip install -U "yt-dlp[default]"
    echo.
    pause
    goto menu
) else if "%MCHOICE%"=="0" (
    exit /b
) else (
    echo Invalid choice. Press any key to try again.
    pause >nul
    goto menu
)
