# Release Notes

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
