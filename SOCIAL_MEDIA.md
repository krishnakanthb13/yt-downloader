# Social Media Announcements

## [v0.0.8] - 2026-04-30

### 💼 Platform 1: LinkedIn
We're excited to announce YouTube Downloader Suite v0.0.8! 🚀

The suite has officially gone cross-platform! Mac and Linux users can now enjoy the exact same frictionless, interactive downloading experience natively using our new Bash (.sh) scripts. 

What's new in v0.0.8?
- 🍎🐧 Cross-Platform Support: Full Mac & Linux compatibility.
- 🛡️ Hardened Bash Security: We've completely overhauled our Unix scripts, implementing Bash Arrays for flag expansions to prevent shell injection, and upgrading input parsing to safely handle complex URLs.
- 🔄 Smart Fallbacks: The built-in yt-dlp updater now automatically detects Unix permission limits and falls back to user-space installations seamlessly.
- 📄 Enhanced Docs: Complete guides for macOS and Linux onboarding.

If you're tired of wrestling with complex CLI arguments for media downloads, give our zero-install interactive suite a try across all major operating systems.

Check out the full release on GitHub!
https://github.com/krishnakanthb13/yt-downloader

#OpenSource #CrossPlatform #Mac #Linux #BashScripting #DevTools #SoftwareEngineering #Automation

---

### 🌐 Platform 2: Reddit
**Subreddits**: r/programming, r/webdev, r/opensource, r/commandline, r/bash, r/linux

**Title**: [Update] YouTube Downloader Suite v0.0.8 - Now Fully Cross-Platform (Mac/Linux Bash Support)

**Body**:
Hey everyone! Following up on our initial release, I'm thrilled to announce version 0.0.8 of the **YouTube Downloader Suite**.

For those who missed it, this project is a zero-install interactive wrapper for `yt-dlp`. It removes the friction of remembering complex CLI arguments by providing a clean, prompt-based UI for quality selection, subtitles, and bulk playlist indexing.

**What's new in v0.0.8?**
The biggest feature request is here: **We've gone Cross-Platform!** 🍎🐧
Alongside the Windows `.bat` files, we've introduced native `.sh` Bash scripts for Mac and Linux. 

But we didn't just port them; we hardened them:
- **Injection-Proof Flags**: Replaced standard space-separated string variables with Bash Arrays `("${ARRAY[@]}")` to dynamically construct yt-dlp arguments, fully preventing shell metacharacter injection.
- **Safe Parsing**: Upgraded all interactive inputs to use `read -rp` to prevent backslash escape issues with messy URLs.
- **Smart Fallbacks**: Added a permission fallback algorithm to our updater that automatically switches to `pip install --user` if your Unix system restricts global installations.

Check out the cross-platform release and source code here: https://github.com/krishnakanthb13/yt-downloader

---

### 🐦 Platform 3: X (Twitter)
YouTube Downloader Suite v0.0.8 is officially Cross-Platform! 🍎🐧🚀

The interactive wrapper for yt-dlp now supports Mac and Linux natively via heavily secured Bash scripts.
🛡️ Array-based injection protection
✅ Smart permission fallbacks
🔗 Safe URL parsing

Check it out on GitHub: https://github.com/krishnakanthb13/yt-downloader

#OpenSource #Bash #Linux #MacOS #DevTools #Automation

---

## [v0.0.6] - 2026-04-30

### 💼 Platform 1: LinkedIn
Excited to announce the initial major release of the YouTube Downloader Suite (v0.0.6)! 🚀

Tired of wrestling with complex command-line arguments for media downloads? The YouTube Downloader Suite is here to remove the friction. It's a powerful collection of interactive Windows batch scripts that act as a user-friendly wrapper for yt-dlp.

What's inside the Suite?
- 🏠 Master Menu: A central orchestrator for all your downloading needs.
- 📺 Video Downloader: Smart quality presets (4K to 360p) + MP3 extraction.
- 📱 Shorts Specialist: Optimized resolutions for mobile content.
- 📂 Bulk Archiver: Sequential downloads for playlists and full channels.
- 💬 Subtitle Support: One-click selection for multi-language subtitles.
- 🔢 Precise Control: Index range support for massive playlists.

Built for simplicity and speed, this suite handles the complex syntax automatically so you can focus on the content. Check out our new premium visual identity and the full feature list on GitHub!

https://github.com/krishnakanthb13/yt-downloader

#OpenSource #YouTubeDownloader #Automation #DevTools #Windows #SoftwareEngineering #productivity

---

### 🌐 Platform 2: Reddit
**Subreddits**: r/programming, r/webdev, r/opensource, r/selfhosted, r/commandline, r/automation

**Title**: [Showcase] YouTube Downloader Suite v0.0.6 - The ultimate interactive wrapper for yt-dlp

**Body**:
Hey everyone! I'm thrilled to share the initial major release (v0.0.6) of the **YouTube Downloader Suite**. 

While `yt-dlp` is an absolute beast for media extraction, its CLI flags can be a bit of a hurdle for everyday use. I built this suite to bridge that gap—providing a set of interactive Windows batch scripts that handle the complex logic behind the scenes.

**Core Features**:
- **Master Orchestrator**: Run `run_downloader.bat` and access everything from a single menu.
- **Smart Quality Mapping**: Automatically maps YouTube's complex formats to simple presets (Best, 1080p, 720p, etc.).
- **Shorts-First Design**: Dedicated logic for Shorts, allowing individual or channel-wide bulk downloads.
- **Bulk & Channel Backups**: sequentially archive entire playlists with automatic folder organization and index range support (e.g., download only items 10-20).
- **Subtitles & Audio**: Built-in support for embedding subtitles and extracting high-quality MP3s.

**Why use it?**
It's portable, requires zero configuration (just standard PATH tools), and makes high-quality media archival accessible to everyone, not just power users.

Check it out here: https://github.com/krishnakanthb13/yt-downloader

---

### 🐦 Platform 3: X (Twitter)
YouTube Downloader Suite v0.0.6 is here! 🚀

The ultimate interactive wrapper for yt-dlp.
📺 4K/HD Video Downloads
🎵 One-click MP3 Extraction
📱 Dedicated Shorts Downloader
📂 Bulk Playlist & Channel Backups
💬 Subtitle Support

Sleek, fast, and interactive.

Check it out on GitHub: https://github.com/krishnakanthb13/yt-downloader

#OpenSource #Automation #YouTube #DevTools #Programming
