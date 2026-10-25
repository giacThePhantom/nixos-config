# focus-dir left|right|up|down: focus the closest window in that direction,
# else the monitor in that direction. Up/down finally cycle the stack, so
# they also work in monocle.
dir=$1
case $dir in
  up) last="focus-view previous" ;;
  down) last="focus-view next" ;;
  *) last="" ;;
esac
river-try "focus-view $dir" "focus-output $dir" ${last:+"$last"} || true
