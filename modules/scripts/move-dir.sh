# move-dir left|right|up|down: swap with the window in that direction, else
# move the window to the monitor in that direction (onto the tags it shows)
# and follow it. Up/down finally swap within the stack, for monocle.
#
# river-try steps prefixed with "!" count when their commands succeed: swap
# fails when there is nothing to swap with (see modules/river/_patches). The send
# step counts when focus reaches the other monitor, i.e. only if there is one.
dir=$1
case $dir in
  up) last="!swap previous" ;;
  down) last="!swap next" ;;
  *) last="" ;;
esac
river-try "!swap $dir" "send-to-output -current-tags $dir; focus-output $dir" ${last:+"$last"} || true
