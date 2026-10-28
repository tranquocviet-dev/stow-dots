#!/usr/bin/env bash

# Perform the action passed as argument
case "$1" in
  raise)
    pactl set-sink-volume @DEFAULT_SINK@ +5%
    ;;
  lower)
    pactl set-sink-volume @DEFAULT_SINK@ -5%
    ;;
  mute)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    ;;
  mic-mute)
    pactl set-source-mute @DEFAULT_SOURCE@ toggle
    ;;
esac

# Get current status using PulseAudio native tools
if [ "$1" = "mic-mute" ]; then
  MUTED=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')
  if [ "$MUTED" = "yes" ]; then
    notify-send -h string:x-canonical-private-synchronous:mic -t 1500 "Microphone" "Muted"
  else
    notify-send -h string:x-canonical-private-synchronous:mic -t 1500 "Microphone" "Unmuted"
  fi
else
  MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
  if [ "$MUTED" = "yes" ]; then
    notify-send -h string:x-canonical-private-synchronous:volume -t 1500 "Volume" "Muted"
  else
    # Extract volume percentage (e.g., "65%" -> "65")
    RAW_VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -n 1)
    notify-send -h string:x-canonical-private-synchronous:volume -h int:value:"$RAW_VOL" -t 1500 "Volume: ${RAW_VOL}%"
  fi
fi
