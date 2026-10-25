#!/bin/sh

# Colors
BG="#222222"
FG="#C5C8C6"
WS_ACT_BG="#285577"
WS_ACT_FG="#FFFFFF"
WS_INACT_BG="#333333"
WS_INACT_FG="#888888"
WS_URG_BG="#A93226"
WS_URG_FG="#FFFFFF"
SEC_FG="#999999"

# -----------------------------------------------------------------------------
# Module Functions
# -----------------------------------------------------------------------------

parse_bspwm() {
    line="$1"
    out=""
    
    # Split bspwm report line by ':'
    old_ifs="$IFS"
    IFS=':'
    set -- $line
    IFS="$old_ifs"

    for item in "$@"; do
        # Extract tag name (strip first character status code)
        type=$(echo "$item" | cut -c1)
        name=$(echo "$item" | cut -c2-)

        case "$type" in
            # Focused occupied / free desktop
            O|F)
                out="${out}%{A1:bspc desktop -f \"${name}\":}%{B${WS_ACT_BG}}%{F${WS_ACT_FG}}  ${name}  %{F-}%{B-}%{A}"
                ;;
            # Unfocused occupied desktop
            o)
                out="${out}%{A1:bspc desktop -f \"${name}\":}%{B${WS_INACT_BG}}%{F${WS_INACT_FG}}  ${name}  %{F-}%{B-}%{A}"
                ;;
            # Urgent desktop
            U|u)
                out="${out}%{A1:bspc desktop -f \"${name}\":}%{B${WS_URG_BG}}%{F${WS_URG_FG}}  ${name}  %{F-}%{B-}%{A}"
                ;;
            # Unfocused empty desktop
            f)
                out="${out}%{A1:bspc desktop -f \"${name}\":}%{B${BG}}%{F${WS_INACT_FG}}  ${name}  %{F-}%{B-}%{A}"
                ;;
        esac
    done
    echo "$out"
}

get_status() {
    # Network IP
    ip=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+')
    if [ -n "$ip" ]; then
        net_str="W: (${ip})"
    else
        net_str="W: down"
    fi

    # Battery
    bat_str=""
    if [ -d /sys/class/power_supply/BAT0 ]; then
        cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
        stat=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
        bat_str=" | BAT: ${cap}% [${stat}]"
    fi

    # Date
    datetime=$(date "+%Y-%m-%d %H:%M:%S")

    echo "%{F${SEC_FG}}${net_str}${bat_str} | ${datetime}%{F-}"
}

# -----------------------------------------------------------------------------
# Main Loop & Piping to Lemonbar
# -----------------------------------------------------------------------------

(
    bspc subscribe report &
    while true; do
        echo "TIME"
        sleep 1
    done
) | while read -r line; do
    case "$line" in
        W*)
            last_wm="$line"
            ;;
    esac

    ws=$(parse_bspwm "$last_wm")
    status=$(get_status)
    
    echo "%{l}${ws}%{r}  ${status}  "
done | lemonbar -b \
  -g x28 \
  -B "$BG" \
  -F "$FG" \
  -f "DejaVu Sans:size=12" \
  -f "DejaVu Sans Mono:size=12" | sh
