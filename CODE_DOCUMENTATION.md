# Code Documentation

## 1. File & Folder Structure

```text
yt-downloader/
│
├── .git/                         # Git version control directory
├── LICENSE                        # GPL v3 License file
├── README.md                      # General project overview
├── CODE_DOCUMENTATION.md          # This file (Technical details)
├── DESIGN_PHILOSOPHY.md           # Design principles and rationale
├── CONTRIBUTING.md                # Guidelines for contributors
│
├── youtube_download.bat           # Script for single video downloads
├── youtube_shorts_download.bat    # Script for YouTube Shorts
└── youtube_bulk_download.bat      # Script for playlists/channels
```

## 2. High-Level Architecture

The project consists of independent Windows Batch scripts that act as interactive wrappers around the `yt-dlp` CLI tool. They provide a user-friendly menu system to capture user preferences and translate them into optimized `yt-dlp` commands.

## 3. Core Modules & Functionality

| Script | Primary Role | Key Parameters Handled |
| :--- | :--- | :--- |
| `youtube_download.bat` | Single Video | URL, Quality (1080p-360p/Best/Audio), Subtitles |
| `youtube_shorts_download.bat` | Shorts (Single/Bulk) | URL, Quality, Range Selection |
| `youtube_bulk_download.bat` | Playlists/Channels | URL, Quality, Subtitles, Range Selection |

## 4. Data Flow

```mermaid
graph TD
    A[User pastes URL] --> B[Select Quality/Subtitles]
    B --> C{Audio Only?}
    C -->|Yes| D[Extract MP3 via yt-dlp]
    C -->|No| E[Download Video + Audio streams]
    E --> F[Merge streams via FFmpeg]
    D --> G[Save to Destination]
    F --> G
```

## 5. Dependencies

### Runtime Dependencies
- **yt-dlp**: Required for fetching media streams.
- **ffmpeg**: Required for post-processing (merging audio/video, audio conversion).

### Developer Dependencies
- None (Vanilla batch scripting).

## 6. Execution Flow

1. **Initialization**: Script sets title, color, and active directory.
2. **Configuration**: Loads hardcoded `SAVE_DIR` (if set) or prompts user.
3. **Input Gathering**: Asks for URL, Quality preference, and additional options (Subtitles/Range).
4. **Command Assembly**: Dynamically builds the `yt-dlp` argument string based on user inputs.
5. **Execution**: Calls `yt-dlp` with assembled flags.
6. **Completion**: Reports success/failure and retains console window via `pause`.
