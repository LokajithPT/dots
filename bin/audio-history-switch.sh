#!/usr/bin/env bash
# Remember-last audio sink: when the current default sink disappears
# (BT powered off, USB unplugged), revert to the most recent sink that
# is still present. Manual switches (pavucontrol, wpctl) are recorded too.

HIST="$HOME/.cache/audio-sink-history"
mkdir -p "$(dirname "$HIST")"; touch "$HIST"

default_sink() { pactl info 2>/dev/null | awk -F': ' '/Default Sink/ {print $2}'; }
sinks()        { pactl list short sinks 2>/dev/null | awk '{print $2}'; }

current=$(default_sink)
[ -n "$current" ] || exit 0   # pipewire-pulse not ready yet; systemd restarts us

push_hist() {
    [ -n "$1" ] || return 0
    [ "$1" != "$(tail -n1 "$HIST")" ] || return 0
    echo "$1" >> "$HIST"
    tail -n 50 "$HIST" > "$HIST.tmp" && mv "$HIST.tmp" "$HIST"
}

pactl subscribe 2>/dev/null |
grep --line-buffered -E "^Event '(change|remove)' on (sink|server)" |
while read -r _ _ event _; do
    new=$(default_sink)

    if [ "$event" = "'change'" ] && [ -n "$new" ] && [ "$new" != "$current" ]; then
        # Default moved to another sink -> remember where we came from.
        push_hist "$current"
        current="$new"

    elif [ "$event" = "'remove'" ]; then
        # A sink vanished. If the default changed as a result, pop back
        # to the newest history entry that still exists.
        [ "$new" != "$current" ] || continue
        prev=""
        while IFS= read -r cand; do
            if [ -n "$cand" ] && [ "$cand" != "$new" ] && sinks | grep -qx "$cand"; then
                prev="$cand"
                break
            fi
        done < <(tac "$HIST")
        if [ -n "$prev" ]; then
            pactl set-default-sink "$prev"
            for si in $(pactl list short sink-inputs | cut -f1); do
                pactl move-sink-input "$si" "$prev" 2>/dev/null
            done
        fi
        current=$(default_sink)
    fi
done
