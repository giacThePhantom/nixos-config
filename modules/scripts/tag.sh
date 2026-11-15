# tag focus|send|follow|toggle N: tag N (1-10) belongs to one monitor, which
# one depending on the monitors connected (scripts/monitors.sh keeps the
# layout), so act on that monitor, moving the window there if needed.
# Then show the tag preview there, which stays up while Super is held.
pressed="${EPOCHREALTIME/./}" # µs; the preview ignores it if Super is up since
action=$1 tags=$((1 << ($2 - 1)))
cur=$(river-output || true)
out=$(awk -v t="$2" '{ n = split($2, a, ","); for (i = 1; i <= n; i++) if (a[i] == t) print $1 }' \
  "${XDG_RUNTIME_DIR:-/tmp}/monitors/layout" 2>/dev/null || true)
out=${out:-$cur} # no layout yet: this monitor
case $action in
  focus)
    # Pressing the tag that is already shown goes back to the previous one
    riverctl focus-output "$out"
    river-bnf "$tags"
    ;;
  toggle)
    riverctl focus-output "$out"
    riverctl toggle-focused-tags "$tags"
    ;;
  send | follow)
    if [ "$cur" != "$out" ]; then
      # Retag while the tag is briefly shown here, so the window stays
      # focused; send-to-output then keeps its tags.
      riverctl toggle-focused-tags "$tags"
      riverctl set-view-tags "$tags"
      riverctl send-to-output "$out"
      riverctl toggle-focused-tags "$tags"
    else
      riverctl set-view-tags "$tags"
    fi
    if [ "$action" = follow ]; then
      riverctl focus-output "$out"
      riverctl set-focused-tags "$tags"
    fi
    ;;
esac
tag-preview show "$(river-output || echo "$out")" "$pressed"
