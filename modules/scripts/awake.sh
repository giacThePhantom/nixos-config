# awake [status]: keep the screen on (no lock, no screens off) until run
# again; Super+Ctrl+Escape or the Power panel. For a talk, a long read, a
# job you're watching. `status` prints on or off, for the panel. The
# inhibitor (river-awake) is tracked by its PID, never by name.
state="${XDG_RUNTIME_DIR:-/tmp}/awake"

running() {
  local pid
  [ -s "$state" ] && read -r pid <"$state" &&
    [ "$(cat "/proc/$pid/comm" 2>/dev/null)" = river-awake ] && echo "$pid"
}

if [ "${1:-}" = status ]; then
  if running >/dev/null; then echo on; else echo off; fi
elif pid="$(running)"; then
  kill "$pid"
  rm -f "$state"
  notify-send -a awake -t 2000 -i system-lock-screen "Screen sleeps again" \
    "Locks after 5 minutes away"
else
  river-awake >/dev/null 2>&1 &
  echo "$!" >"$state"
  notify-send -a awake -t 2000 -i video-display "Screen stays on" \
    "Until Super+Ctrl+Escape"
fi
