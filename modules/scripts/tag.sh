# tag focus|send|follow|toggle TAGMASK OUTPUT: tags belong to a fixed monitor
# (settings.nix), so act on that monitor, moving the window there if needed.
# Then show the tag preview there, which stays up while Super is held.
pressed="${EPOCHREALTIME/./}" # µs; the preview ignores it if Super is up since
action=$1 tags=$2 out=$3
cur=$(river-output || true)
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
