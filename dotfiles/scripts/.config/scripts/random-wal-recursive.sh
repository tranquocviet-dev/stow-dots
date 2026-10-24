#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/kuuko/"

# 1. Parse optional flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --none|-n)
      xfconf-query -c xfce4-desktop -l | grep "image-style$" | while read -r prop; do
        xfconf-query -c xfce4-desktop -p "$prop" -s 0
      done
      exit 0
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

# Expand tilde if passed manually as a string (e.g. "~/Wallpapers")
WALLPAPER_DIR="${WALLPAPER_DIR/#\~/$HOME}"

# 2. Pick a random image (-L follows symlinks)
WALLPAPER=$(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.jpeg" \) 2>/dev/null | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
  echo "Error: No images found in $WALLPAPER_DIR" >&2
  exit 1
fi

# 3. Determine image aspect ratio
read -r WIDTH HEIGHT <<< "$(identify -format "%w %h" "$WALLPAPER" 2>/dev/null)"

# If vertical or 1x1 (height >= width), set style to 4; else set to 5
if [ -n "$WIDTH" ] && [ -n "$HEIGHT" ] && [ "$HEIGHT" -ge "$WIDTH" ]; then
  STYLE=4
else
  STYLE=5
fi

# 4. Update xfconf properties safely line-by-line
xfconf-query -c xfce4-desktop -l | grep "last-image$" | while read -r prop; do
  xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPER"
  
  style_prop="${prop%last-image}image-style"
  xfconf-query -c xfce4-desktop -p "$style_prop" -s "$STYLE" 2>/dev/null || true
done
