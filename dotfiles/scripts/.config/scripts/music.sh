#!/usr/bin/env bash

# Perform the action passed as argument
case "$1" in
  raise)
    wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
    ;;
  lower)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    ;;
  mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    ;;
  mic-mute)
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    ;;
esac

# Get current status
if [ "$1" = "mic-mute" ]; then
  STATE=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
  if [[ "$STATE" =~ \[MUTED\] ]]; then
    notify-send -h string:x-canonical-private-synchronous:mic -t 1500 "Microphone" "Muted"
  else
    notify-send -h string:x-canonical-private-synchronous:mic -t 1500 "Microphone" "Unmuted"
  fi
else
  STATE=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
  if [[ "$STATE" =~ \[MUTED\] ]]; then
    notify-send -h string:x-canonical-private-synchronous:volume -t 1500 "Volume" "Muted"
  else
    # Parse volume decimal (e.g. 0.65 -> 65%)
    RAW_VOL=$(echo "$STATE" | awk '{print $2}')
    VOL=$(awk -v v="$RAW_VOL" 'BEGIN { printf "%.0f", v * 100 }')
    # -h int:value:$VOL displays a progress bar in Dunst/Mako
    notify-send -h string:x-canonical-private-synchronous:volume -h int:value:"$VOL" -t 1500 "Volume: ${VOL}%"
  fi
fi
