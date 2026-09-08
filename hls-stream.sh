#!/usr/bin/env bash

set -euo pipefail

echo "=============================================="
echo "  HLS Stream Finder + yt-dlp Downloader"
echo "=============================================="
echo

read -rp "Paste the watch page URL: " PAGE_URL

if [[ -z "$PAGE_URL" ]]; then
    echo "No URL provided. Exiting."
    exit 1
fi

DOMAIN=$(echo "$PAGE_URL" | awk -F/ '{print $1"//"$3}')

echo
echo "→ Analyzing page at $DOMAIN..."

HTML=$(curl -sL -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
    -H "Referer: ${DOMAIN}/" \
    "$PAGE_URL")

SOURCES_PATH=$(echo "$HTML" | grep -oE '/api/v1/(videos|episodes|player-log)/[0-9]+/sources' | head -n1)

if [[ -z "$SOURCES_PATH" ]]; then
    SOURCES_PATH=$(echo "$HTML" | grep -oE '/api/v1/[^"[:space:]]+' | head -n1)
fi

if [[ -z "$SOURCES_PATH" ]]; then
    echo "❌ Could not find sources API path on the page. Trying native yt-dlp extraction..."
    yt-dlp "$PAGE_URL"
    exit 0
fi

echo "→ Found sources endpoint: $SOURCES_PATH"
echo "→ Fetching stream info..."

RESPONSE=$(curl -sL -A "Mozilla/5.0" \
    -H "Referer: $PAGE_URL" \
    -H "Accept: application/json" \
    "${DOMAIN}${SOURCES_PATH}")

# Extract the base URL from the JSON "file" field or general response
BASE=$(echo "$RESPONSE" | grep -oE '"file"[[:space:]]*:[[:space:]]*"[^"]+"' | grep -oE 'https?://[^"]+' | head -n1)

if [[ -z "$BASE" ]]; then
    BASE=$(echo "$RESPONSE" | grep -oE 'https?://[^"]+' | head -n1)
fi

if [[ -n "$BASE" ]]; then
    BASE=$(echo "$BASE" | sed 's/"//g')
    if [[ "$BASE" == *.m3u8 || "$BASE" == *.json ]]; then
        PLAYLIST="$BASE"
    else
        PLAYLIST="${BASE}/index.json"
    fi
else
    PLAYLIST=""
fi

if [[ -z "$PLAYLIST" ]]; then
    echo "❌ No HLS stream found in the sources response."
    echo "Raw response:"
    echo "$RESPONSE"
    exit 1
fi

echo
echo "✅ Found stream playlist:"
echo
echo "    $PLAYLIST"
echo

read -rp "Download with yt-dlp? [y/N]: " ANSWER

if [[ "${ANSWER,,}" == "y" || "${ANSWER,,}" == "yes" ]]; then
    echo
    echo "→ Starting download with yt-dlp..."
    echo

    TITLE=$(echo "$HTML" | grep -o '<title>[^<]*' | head -n1 | \
            sed -E 's/<title>//; s/^Watch //; s/ \|.*//; s/[^a-zA-Z0-9]+/_/g; s/^_|_$//g')

    if [[ -z "$TITLE" ]]; then
        TITLE="downloaded_video"
    fi

    yt-dlp \
        --no-warnings \
        -o "${TITLE}.%(ext)s" \
        --merge-output-format mp4 \
        "$PLAYLIST"

    echo
    echo "✅ Download finished → ${TITLE}.mp4"
else
    echo
    echo "Playlist kept visible above."
    echo
    echo "You can download later with:"
    echo
    echo "  yt-dlp \"$PLAYLIST\""
    echo
fi