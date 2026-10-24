#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/Pictures/kuuko/"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/icewm"
STATE_FILE="$STATE_DIR/wallpaper"

# Function to determine screen resolution and aspect ratio, then set wallpaper accordingly
set_wallpaper() {
  local img="$1"
  if [ ! -f "$img" ]; then
    echo "Error: Image file not found: $img" >&2
    return 1
  fi

  # Determine image dimensions
  read -r width height <<< "$(identify -format "%w %h" "$img" 2>/dev/null)"
  
  if [ -z "$width" ] || [ -z "$height" ]; then
    xwallpaper --daemon --zoom "$img"
    return 0
  fi

  # Try to get screen resolution for precise ratio comparison
  local screen_w="" screen_h=""
  if command -v xrandr &>/dev/null; then
    read -r screen_w screen_h <<< "$(xrandr 2>/dev/null | awk '/\bconnected/ {getline; print $1; exit}' | tr 'x' ' ')"
  elif command -v xdpyinfo &>/dev/null; then
    read -r screen_w screen_h <<< "$(xdpyinfo 2>/dev/null | awk '/dimensions:/ {print $2}' | tr 'x' ' ')"
  fi

  local style="zoom"
  if [ -n "$screen_w" ] && [ -n "$screen_h" ] && [ "$screen_h" -gt 0 ] && [ "$screen_w" -gt 0 ]; then
    # Compare aspect ratios using cross-multiplication to avoid floats: (width * screen_h) vs (screen_w * height)
    local img_ratio_side=$(( width * screen_h ))
    local screen_ratio_side=$(( screen_w * height ))

    if [ "$height" -ge "$width" ]; then
      style="maximize"
    elif [ "$img_ratio_side" -lt "$screen_ratio_side" ]; then
      style="zoom"
    else
      style="maximize"
    fi
  else
    # Fallback heuristic if screen dimensions cannot be fetched
    if [ "$height" -ge "$width" ]; then
      style="maximize"
    else
      style="zoom"
    fi
  fi

  xwallpaper --daemon --"$style" "$img"
}

load_cached() {
  if [ -s "$STATE_FILE" ]; then
    local img_path
    img_path=$(tr -d '\r\n' < "$STATE_FILE" | head -n 1)
    img_path="${img_path/#\~/$HOME}"
    if [ -f "$img_path" ]; then
      set_wallpaper "$img_path"
      return 0
    fi
  fi
  return 1
}

# 1. Parse optional flags
FORCE_CACHED=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --none|-n)
      xwallpaper --daemon --clear
      exit 0
      ;;
    --cached|-c)
      FORCE_CACHED=true
      shift
      ;;
    --path|-p)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        WALLPAPER_DIR="$2"
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Expand tilde if passed manually as a string
WALLPAPER_DIR="${WALLPAPER_DIR/#\~/$HOME}"

if [ "$FORCE_CACHED" = true ]; then
  if ! load_cached; then
    echo "Error: No valid cached wallpaper found in $STATE_FILE" >&2
    exit 1
  fi
  exit 0
fi

# 2. Pick a random image (-L follows symlinks)
WALLPAPER=$(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.jpeg" \) 2>/dev/null | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
  echo "Error: No images found in $WALLPAPER_DIR" >&2
  exit 1
fi

# 3. Save to cache and set wallpaper
mkdir -p "$STATE_DIR"
printf '%s\n' "$WALLPAPER" > "$STATE_FILE"

set_wallpaper "$WALLPAPER"
