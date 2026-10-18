# Change Report: Configuration & Hardening Pass

This document records a pass over the YouTube Downloader Suite that removed a
hardcoded personal path, introduced a configuration file, and fixed or improved the
other code-level issues found during a review.

> This file previously contained an unrelated AI chat transcript. It has been replaced
> with this report. A second transcript (`cg.md`) was removed entirely.

---

## 1. Goal

- The repository is public, but all three downloader scripts contained a hardcoded
  personal save path (`D:\My Private Path\Videos`, redacted here). Personal paths must never be committed.
- The save location must instead come from configuration, and the scripts must ask the
  user for a folder when nothing is configured.
- Fix the remaining code-level issues found in review without introducing regressions.

---

## 2. Save Location: from hardcoded to config-driven

Before:

```bat
:: HARDCODE YOUR SAVE LOCATION HERE
set "SAVE_DIR=D:\My Private Path\Videos"
```

After:

- A committed template, `downloader.conf.example`, documents the format.
- The real `downloader.conf` is **git-ignored**, so a personal path is never published.
- Each script reads `SAVE_DIR` from `downloader.conf` (in the same folder as the script).
- If the file is missing, or `SAVE_DIR` is empty, the script prompts for a folder and
  falls back to a sensible default (`Downloads`, or `Shorts` for the shorts script).
- Nothing is auto-created or auto-saved.

How each platform reads the file:

| Platform | Approach |
| :--- | :--- |
| Bash (`.sh`) | `sed` extracts the value (the file is never `source`d, so it cannot execute code). Works with comments, spaces, and CRLF line endings. |
| Batch (`.bat`) | `for /f "usebackq eol=# tokens=1,* delims=="`. Read **before** enabling delayed expansion so a `!` in a path is preserved. |

---

## 3. Bugs Fixed

| # | Bug | Where | Fix |
| :- | :--- | :--- | :--- |
| 1 | Hardcoded personal save path committed to a public repo | all three downloaders (`.bat` + `.sh`) | Replaced with `downloader.conf` / prompt. |
| 2 | A folder typed at the "Output folder" prompt was silently discarded and replaced with the default | `.bat` scripts | The follow-up check used parse-time `%SAVE_DIR%`; changed to run-time `!SAVE_DIR!`. |
| 3 | `run_downloader.bat` update menu always ran `python -m pip`, ignoring whether `python` existed | `run_downloader.bat` | `%errorlevel%` was expanded at parse time inside the `if` block. Moved the logic into a subroutine that uses the run-time `if not errorlevel 1` form, and added real fall-through. |
| 4 | `run_downloader.sh` updater stopped at the first *installed* tool even when its command failed | `run_downloader.sh` | Replaced the `if/elif` chain with sequential attempts that continue until one **succeeds**. |
| 5 | Save directory creation was not verified | all downloaders | After `mkdir`, the scripts confirm the folder exists and fail with a clear message. |
| 6 | `open` / `xdg-open` could abort the script under `set -e` | `.sh` scripts | Guarded with `|| true`. |
| 7 | Shell test runner used the GNU-only `grep -oP` | `tests/run_all_tests.sh` | Replaced with portable `sed`. |
| 8 | Test regex `title\.150s` could never match the real `%(title).150s` output template | `tests/test_batch_files.ps1` | Corrected the regex; this test was failing before this pass. |

---

## 4. Improvements

- **URL validation**: empty or non-`http(s)` URLs are rejected before `yt-dlp` is called.
- **Download-range validation**: ranges accept only digits, commas, and hyphens, so bad
  input can never be interpreted as extra `yt-dlp` arguments.
- **`--no-playlist`** is now passed in single video / single short mode, so a URL that
  also references a playlist downloads only the one item.
- **JavaScript runtime auto-detection**: `--js-runtimes node` is added automatically
  only when Deno is absent and Node.js is present. `--remote-components ejs:github` is
  still always passed.
- **Portable empty-array expansion**: Bash flags use `"${ARR[@]+"${ARR[@]}"}"`, which is
  safe under `set -u` even on the Bash 3.2 shipped with macOS.
- **Clearer status output**: the "Files saved in..." / "Output" lines print the resolved
  folder (including a folder typed at the prompt).
- **Windows parity**: the `.bat` scripts now run the same connectivity check
  (`curl --connect-timeout 5`, warning only) and the same MP3 / `ffmpeg` enforcement as the
  `.sh` scripts. Previously both checks existed only in the Unix scripts.
  - Note: in batch, parentheses inside an `if (...)` block must be escaped as `^(` `^)`,
    so the error text `(mp3)` is written `^(mp3^)`. Unescaped, it is a *parse* error that
    breaks the whole block — even when the branch is never taken.

---

## 5. Files Changed

New:

- `downloader.conf.example` — configuration template.

Modified:

- `youtube_download.bat` / `.sh`
- `youtube_bulk_download.bat` / `.sh`
- `youtube_shorts_download.bat` / `.sh`
- `run_downloader.bat` / `.sh`
- `.gitignore` (ignores `downloader.conf`)
- `README.md`, `CODE_DOCUMENTATION.md`, `RELEASE_NOTES.md`, `CONTRIBUTING.md`,
  `DESIGN_PHILOSOPHY.md`, `SOCIAL_MEDIA.md`
- `tests/run_all_tests.sh`, `tests/run_all_tests.ps1`,
  `tests/test_batch_files.ps1`, `tests/test_common.sh`,
  `tests/test_youtube_download.sh`

Removed:

- `cg.md` — an unrelated AI chat transcript.

Documentation:

- `ds.md` — this report (was an unrelated AI chat transcript).

---

## 6. Tests

Added coverage for every new behaviour, including functional tests that actually execute
the scripts against a mocked `yt-dlp`:

- Config-driven `SAVE_DIR` reaches `yt-dlp` (shell **and** batch).
- `--no-playlist` is passed in single mode.
- An invalid URL is rejected before `yt-dlp` runs.
- `downloader.conf` is read and `downloader.conf.example` exists.
- Static checks for URL/range validation and the JavaScript runtime flag.
- Batch parity, both static and functional:
  - the connectivity warning fires when `curl` reports an offline state,
  - MP3 extraction is refused (and `yt-dlp` is never called) when `ffmpeg` is missing.

The batch functional tests compile a tiny `curl.exe` stub so no real network request is
made. A `.bat` mock cannot be used here: a batch file invoked without `CALL` does not
return control to the caller.

Results after this pass:

| Suite | Result |
| :--- | :--- |
| `tests/run_all_tests.sh` | 302 / 302 passed |
| `tests/run_all_tests.ps1` | 135 / 135 passed |
| `tests/test_batch_files.ps1` | 74 / 74 passed |

---

## 7. How to Verify

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File tests/run_all_tests.ps1
powershell -ExecutionPolicy Bypass -File tests/test_batch_files.ps1
```

```bash
# macOS / Linux
bash tests/run_all_tests.sh
```

Manual check: copy `downloader.conf.example` to `downloader.conf`, set `SAVE_DIR`, run a
downloader, and confirm the file lands in that folder. Then delete `SAVE_DIR`'s value and
confirm the script prompts for a folder instead.

Parity check: disconnect from the network and run each downloader — every one should warn
"Could not connect to youtube.com" and still proceed. Then choose `Audio only (mp3)` on a
machine without `ffmpeg` — `youtube_download` and `youtube_bulk_download` should refuse to
run, while `youtube_shorts` (no audio mode) only warns.

---

## 8. Notes & Known Limitations

- `downloader.conf` currently supports a single key, `SAVE_DIR`. Parsing rules: one
  `NAME=VALUE` per line, no spaces around `=`, and `#` starts a comment.
- The value is used verbatim — `~` and `$HOME` are **not** expanded, so an absolute path
  should be written out in full.
- Batch files are read before delayed expansion is enabled; extremely unusual paths that
  contain a literal `!` may still be mangled when echoed.
- `core.autocrlf=true` is set with no `.gitattributes`; a `.gitattributes` would make
  cross-platform line endings more predictable if desired later.
