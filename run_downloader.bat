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
    call :update_ytdlp
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

:update_ytdlp
echo ============================================
echo  Updating yt-dlp...
echo ============================================
:: Try each installer in turn until one succeeds.
:: This is a subroutine on purpose: inside a normal if block,
:: "%errorlevel%" is expanded too early, so the old code always
:: ran the first command regardless of whether it existed.
set "UPDATED=no"

where pipx >nul 2>&1
if not errorlevel 1 (
    pipx upgrade yt-dlp
    if not errorlevel 1 set "UPDATED=yes"
)

if "%UPDATED%"=="no" (
    where pip3 >nul 2>&1
    if not errorlevel 1 (
        pip3 install -U "yt-dlp[default]"
        if not errorlevel 1 set "UPDATED=yes"
    )
)

if "%UPDATED%"=="no" (
    where pip >nul 2>&1
    if not errorlevel 1 (
        pip install -U "yt-dlp[default]"
        if not errorlevel 1 set "UPDATED=yes"
    )
)

if "%UPDATED%"=="no" (
    where python >nul 2>&1
    if not errorlevel 1 (
        python -m pip install -U "yt-dlp[default]"
        if not errorlevel 1 set "UPDATED=yes"
    )
)

if "%UPDATED%"=="no" (
    yt-dlp -U
    if not errorlevel 1 set "UPDATED=yes"
)

echo.
if "%UPDATED%"=="yes" (
    echo yt-dlp updated successfully.
) else (
    echo Could not update yt-dlp automatically.
    echo Reinstall it manually if needed ^(see the README^).
)
exit /b
