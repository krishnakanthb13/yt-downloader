# Release Notes

## [Unreleased]
### 🚀 New Features
- **Config File (`downloader.conf`)**: The default save folder is now read from an optional, git-ignored `downloader.conf` (copy from `downloader.conf.example`). Personal paths are no longer hardcoded in the scripts, and users are prompted when it is not set.

### ⚡ Improvements
- **Status Messages**: Clear "Files saved in..." messages now print the actual resolved output folder (including folders typed at the prompt).
- **URL & Range Validation**: URLs must start with `http://`/`https://`, and download ranges accept only digits, commas, and hyphens before `yt-dlp` is invoked.
- **JavaScript Runtime Auto-Detection**: `--js-runtimes node` is passed automatically when Deno is not installed but Node.js is.
- **Single-Item Downloads**: Single video/short downloads now pass `--no-playlist`, so a URL that also contains a `&list=` parameter downloads just the one item.
- **Reliable yt-dlp Updater**: The updater now tries each installer in turn and only stops when one succeeds. Previously the Windows menu always ran the first command, because `%errorlevel%` was expanded too early inside the `if` block.
- **Portable Tests**: The shell test runner no longer relies on the GNU-only `grep -oP`.
- **Safer Empty Arrays**: Bash flag arrays are expanded with the `"${ARR[@]+"${ARR[@]}"}"` guard so `set -u` never aborts on an empty array (also works on the Bash 3.2 shipped with macOS).
- **Windows Parity**: The `.bat` scripts now run the same connectivity check and enforce `ffmpeg` for MP3 extraction that the Unix scripts already did, so both platforms behave identically.

### 🐛 Bug Fixes
- **Save-Folder Prompt**: A folder typed at the "Output folder" prompt is no longer overwritten with the default value.
- **Save-Folder Check**: The scripts now confirm the save folder actually exists after `mkdir` and fail with a clear message otherwise.

### 📚 Documentation
- Documented `downloader.conf`, the new validation, and the Node.js fallback, and added static + functional regression tests.

---

## [v0.0.8] - 2026-04-30
### 🚀 New Features
- **Cross-Platform Unix Support**: Mac and Linux users can now run the suite natively using the new `.sh` Bash scripts, mirroring the complete functionality of the Windows `.bat` versions.
- **Smart Update Fallback**: The yt-dlp updater now automatically falls back to `--user` mode on Mac/Linux if a system-wide permission error occurs.

### ⚡ Improvements
- **Hardened Bash Security**: Complete overhaul of the Unix `.sh` scripts. Replaced space-separated string flags with Bash Arrays (`"${ARRAY[@]}"`) to fully prevent shell metacharacter injection and word splitting.
- **Robust Input Parsing**: Switched to `read -rp` across all interactive prompts to safely handle backslashes and special characters in URLs and path inputs.
- **Graceful Error Handling**: Added strict verification for download directory creation (`mkdir -p`), ensuring the script fails safely if write permissions are denied.

### 📚 Documentation
- **Mac/Linux Onboarding**: Updated the README and Code Documentation to include `.sh` execution instructions (`chmod +x`).
- **Security Audit Docs**: Added a dedicated section detailing Unix script security hardening in `CODE_DOCUMENTATION.md`.

---

## [v0.0.6] - 2026-04-30
### 🚀 New Features (Initial Release)
- **Master Menu Orchestrator**: A central hub (`run_downloader.bat`) to access all downloader scripts instantly.
- **Standalone Video Downloader**: Download any YouTube video with quality presets (Best to 360p) and MP3 conversion.
- **Shorts Specialist**: Dedicated script for YouTube Shorts with mobile-optimized resolution mapping.
- **Bulk Playlist & Channel Backup**: Mass download entire playlists or channel uploads with sequential processing and folder organization.
- **Smart Subtitle Support**: Interactive selection for English, Tamil, or all available subtitles.
- **Index Range Control**: Specify exactly which videos to download from a playlist (e.g., items 5 to 15).
- **Auto-Update Utility**: Integrated feature to keep `yt-dlp` updated to the latest version.

### ⚡ Improvements
- **Interactive UI**: Replaced complex CLI flags with a user-friendly, prompt-based interaction system.
- **Visual Identity**: Introduced a premium high-tech branding with glassmorphism assets.

### 📚 Documentation
- **Comprehensive Guide**: Detailed README and code documentation for users and contributors.
- **Architecture Overview**: Added Mermaid diagrams to visualize script connectivity.

### 🏗️ Infrastructure & Maintenance
- **Dependency Management**: Standardized requirements for `yt-dlp`, `ffmpeg`, and JavaScript runtimes.
- **Asset Pipeline**: Organized project media within a dedicated `assets/` directory.
