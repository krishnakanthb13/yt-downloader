# Design Philosophy

## 1. Problem Definition
CLI tools like `yt-dlp` offer unmatched power but suffer from high cognitive load. Users who just want to download a video at a specific quality often struggle with command syntax, leading to frustration or reliance on shady ad-filled web downloaders.

## 2. Why This Solution?
Windows Batch scripts provide a **zero-install runtime environment** on Windows systems. They act as an interface layer, bridging the gap between a raw CLI tool and the user without requiring a heavy GUI application framework.

## 3. Design Principles
- **Simplicity First**: Clean interactive prompts requiring minimal keyboard input (mostly numbers 1-6).
- **Resilience**: Configured with default retry limits (`--retries 5`) to handle spotty internet connections.
- **Transparency**: Clearly echoes back user choices before initiating the download payload.

## 4. Target Audience & Use Cases
- Users wanting quick offline access to educational content.
- Content creators archiving their own bulk uploads.
- Users in bandwidth-constrained environments preferring audio-only formats.

## 5. Trade-offs & Constraints
- **OS Lock-in**: Only works natively on Windows.
- **Maintenance**: Heavily reliant on `yt-dlp` updates when YouTube changes its internal APIs.
