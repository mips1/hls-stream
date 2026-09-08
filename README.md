# HLS Stream Finder & Downloader

A lightweight, interactive Bash script that automatically detects, extracts, and downloads HTTP Live Streaming (HLS) video manifests (`.m3u8` or `.json`) from media web pages using [`yt-dlp`](https://github.com/yt-dlp/yt-dlp).

**Features**
* **Automated Stream Detection:** Scans web pages and API endpoints to extract hidden HLS manifests (`.m3u8` or `index.json`).
* **Dynamic Headers:** Automatically constructs domain-based `Referer` and `Origin` headers to bypass hotlink protections and HTTP 403 errors.
* **Smart Title Extraction:** Generates clean, filesystem-safe output filenames directly from webpage `<title>` tags.
* **`yt-dlp` Native Fallback:** Automatically passes the page URL directly to `yt-dlp`'s built-in extractors if custom API parsing yields no manifest.
* **Cross-Platform Compatibility:** Written using POSIX-compliant syntax to run natively across Linux, macOS (`bash` 3.2+), and Windows environments.

**Prerequisites**
Ensure you have **Bash**, **curl**, **ffmpeg**, and **`yt-dlp`** installed on your system.

* **Linux (Ubuntu / Debian / Fedora)**
    ```bash
    sudo apt update && sudo apt install -y curl grep sed ffmpeg python3 python3-pip
    pip install --user --upgrade yt-dlp
    ```

* **macOS**
    ```bash
    brew update
    brew install bash curl ffmpeg yt-dlp
    ```

* **Windows**
    ```cmd
    winget install FFmpeg
    winget install yt-dlp
    winget install Git.Git
    ```
    *(Run the script inside **Git Bash** or **WSL**)*

**Getting Started & Execution**

1. **Clone the Repository**
    ```bash
    git clone [https://github.com/mips1/hls-stream.git](https://github.com/mips1/hls-stream.git)
    cd hls-stream
    ```

2. **Make the Script Executable**
    ```bash
    chmod +x hls-stream.sh
    ```

3. **Run the Script**
    ```bash
    ./hls-stream.sh
    ```

**How It Works**
1. **URL Input:** Paste the target watch page URL when prompted by the script.
2. **Analysis:** The script fetches the page HTML, constructs dynamic request headers based on the domain, and scans for direct HLS playlist URLs or `/api/` endpoints.
3. **Extraction:** If an HLS playlist URL (`.m3u8` or `index.json`) is found, it displays the direct link in your console.
4. **Download:** Confirm with `y` to begin downloading via `yt-dlp`, or copy the printed manifest URL to run manual commands with `yt-dlp` or `ffmpeg`.
5. **Fallback:** If no manifest is detected through API scraping, the script automatically attempts native extraction by handing the page URL directly to `yt-dlp`.

Distributed under the [MIT License](LICENSE).