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
├── run_downloader.bat / .sh             # Master orchestrator script
├── youtube_download.bat / .sh           # Script for single video downloads
├── youtube_shorts_download.bat / .sh    # Script for YouTube Shorts
└── youtube_bulk_download.bat / .sh      # Script for playlists/channels
```

## 2. High-Level Architecture

The project utilizes a hub-and-spoke architecture. `run_downloader.bat` serves as the central hub, executing the specialized scripts based on user requirements.

## 3. Core Modules & Functionality

| Script | Primary Role | Key Parameters Handled |
| :--- | :--- | :--- |
| `run_downloader` (.bat/.sh) | Master Menu | Option Selection (0-4), Safe pip update fallback |
| `youtube_download` (.bat/.sh) | Single Video | URL, Quality (1080p-360p/Best/Audio), Subtitles |
| `youtube_shorts_download` (.bat/.sh) | Shorts (Single/Bulk) | URL, Quality, Range Selection |
| `youtube_bulk_download` (.bat/.sh) | Playlists/Channels | URL, Quality, Subtitles, Range Selection |

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
- None (Vanilla batch and bash scripting).

## 6. Security and Robustness (Unix)

The `.sh` scripts for Mac and Linux are hardened against common shell vulnerabilities:
1. **Safe Input Parsing**: Interactive prompts use `read -rp` to read variables without interpreting backslash escape sequences.
2. **Safe Array Expansion**: Argument flags (like `--playlist-items` or `--write-subs`) are dynamically generated as Bash Arrays `("${ARRAY[@]}")` rather than space-separated strings. This prevents command injection vulnerabilities.
3. **Graceful Error Handling**: Directory creation (`mkdir -p`) is strictly verified, exiting safely with meaningful errors if write permissions are denied. The `pip` update routine includes automatic fallback to `--user` installation mode.

## 7. Execution Flow

1. **Entry Point**: User launches `run_downloader.bat`.
2. **Routing**: User selects a script, which is launched via `call`.
3. **Initialization**: The targeted script sets its specific environment.
4. **Input Gathering**: Captures URL, quality choices, and filter parameters.
5. **Command Assembly**: Dynamically builds the `yt-dlp` argument payload.
6. **Execution**: Calls `yt-dlp` with assembled flags.
7. **Loopback**: Returns control to the master menu upon completion.
