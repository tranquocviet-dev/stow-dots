#!/usr/bin/env bash

# Height trigger area in pixels from top of screen
TRIGGER_HEIGHT=30
STATE="shown"

# Ensure Polybar IPC is ready
polybar-msg cmd show &>/dev/null || exit 1

while true; do
  # Get current Y position of mouse cursor
  Y_POS=$(xdotool getmouselocation 2>/dev/null | awk -F '[ :]' '{print $4}')

  if [ -n "$Y_POS" ]; then
    if [ "$Y_POS" -le "$TRIGGER_HEIGHT" ] && [ "$STATE" = "hidden" ]; then
      polybar-msg cmd show
      STATE="shown"
    elif [ "$Y_POS" -gt 100 ] && [ "$STATE" = "shown" ]; then
      polybar-msg cmd hide
      STATE="hidden"
    fi
  fi
  sleep 0.2
done
