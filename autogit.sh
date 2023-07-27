#!/bin/bash

# Function to display script usage
usage() {
    echo "autogit version 1.0"
    echo ""
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -u, --url <url>     Download the latest release from a single URL"
    echo "  -l, --list <file>   Download the latest releases from URLs listed in a file"
    echo "  -h, --help          Display this help message"
    echo ""
    echo "Example:"
    echo "  $0 -u \"https://api.github.com/repos/anotheruser/anotherproject/releases\""
}

# Check for the presence of options
if [ "$#" -eq 0 ]; then
    usage >&2
    exit 1
fi

# Parse the command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -u|--url)
            # Process URL option
            shift
            if [ -z "$1" ]; then
                echo "Error: URL is missing for --url option." >&2
                usage >&2
                exit 1
            fi
            url="$1"
            download_latest_release "$url"
            shift
            ;;
        -l|--list)
            # Process list option
            shift
            if [ -z "$1" ]; then
                echo "Error: File is missing for --list option." >&2
                usage >&2
                exit 1
            fi
            file="$1"
            while IFS= read -r url; do
                download_latest_release "$url"
            done < "$file"
            shift
            ;;
        -h|--help)
            # Display help and exit
            usage
            exit 0
            ;;
        *)
            # Unknown option, skip
            shift
            ;;
    esac
done

# Function to download the latest release for a given URL
download_latest_release() {
    local url=$1
    local download_url=$(curl -s "$url" | grep -o '"browser_download_url": "[^"]*' | grep "linux_amd64" | cut -d'"' -f4 | sort -V | tail -n1)
    local filename="latest_release"

    # Determine the archive file extension
    if [[ $download_url == *.zip ]]; then
        filename="${filename}.zip"
    elif [[ $download_url == *.tar.gz || $download_url == *.tgz ]]; then
        filename="${filename}.tar.gz"
    else
        echo "[?] Unknown archive format for URL: $url"
        return
    fi

    echo "Downloading $filename..."
    curl -s -L -o "$filename" "$download_url" &>/dev/null
    echo "Download complete."

    # Extract the downloaded archive based on its extension
    if [[ $filename == *.zip ]]; then
        echo "[+] Extracting $filename..."
        unzip -q "$filename" -d /opt/
        echo "[+] Extraction complete."
    elif [[ $filename == *.tar.gz ]]; then
        echo "[+] Extracting $filename..."
        tar -zxf "$filename" -C /opt/
        echo "[+] Extraction complete."
    fi

    rm "$filename"
}

# Check for the presence of options
if [ "$#" -eq 0 ]; then
    echo "[x] Error: No options provided."
    usage
    exit 1
fi

# Read URLs from user input or file
urls=()
while getopts "u:l:h" opt; do
    case $opt in
        u) urls+=("$OPTARG") ;;  # Single URL provided with -u or --url
        l) mapfile -t urls < "$OPTARG" ;;  # Read URLs from file provided with -l or --list
        h) usage
           exit 0 ;;
        \?) echo "[x] Invalid option: -$OPTARG" >&2
            usage
            exit 1 ;;
        :) echo "[?] Option -$OPTARG requires an argument." >&2
           usage
           exit 1 ;;
    esac
done

# Check if at least one URL is provided
if [ "${#urls[@]}" -eq 0 ]; then
    echo "[x] Error: No URLs provided."
    usage
    exit 1
fi

# Loop through the list of URLs and download the latest release for each
for url in "${urls[@]}"; do
    download_latest_release "$url"
done
