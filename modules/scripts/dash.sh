# dash open|toggle PANEL | dash close: the dashboard panels, eww windows
# named hub (the menu), calendar, media, system and power. One is open at a
# time, on the primary monitor. While one is open river is in "dashboard"
# mode (letters switch panels, Escape closes), and only that panel's polls run
# (the eww variable `panel`). The eww daemon starts with the session
# (river/autostart.nix); if it really is not running, this starts it.

# eww commands wait only 100 ms for the daemon; when it is slower, `eww
# daemon` and a plain `eww open` take it for dead and start a second one,
# whose windows then can't be closed. Hence the patience below, and
# --no-daemonize on open (see tag-preview.sh).
running() { eww ping >/dev/null 2>&1; }
current() { if running; then eww get panel; fi; }
ensure_daemon() {
  for _ in $(seq 100); do running && return 0; sleep 0.02; done
  if ! pgrep -u "$(id -u)" -f '^([^ ]*/)?eww daemon' >/dev/null; then
    eww daemon
    for _ in $(seq 100); do running && return 0; sleep 0.02; done
  fi
}

open() {
  ensure_daemon
  shown="$(current)"
  if [ -n "$shown" ]; then eww close "$shown" >/dev/null 2>&1 || true; fi
  eww update panel="$1"
  # The primary monitor, or the first one if it's unplugged
  screen=0
  for status in /sys/class/drm/card*-"$PRIMARY_OUTPUT"/status; do
    if [ "$(cat "$status" 2>/dev/null)" = connected ]; then screen="$PRIMARY_OUTPUT"; fi
  done
  eww --no-daemonize open "$1" --screen "$screen" || true
  riverctl enter-mode dashboard
}

close() {
  shown="$(current)"
  if [ -n "$shown" ]; then
    eww close "$shown" >/dev/null 2>&1 || true
    eww update panel=
  fi
  riverctl enter-mode normal
}

case "${1:-}" in
  open) open "$2" ;;
  close) close ;;
  toggle) if [ "$(current)" = "$2" ]; then close; else open "$2"; fi ;;
  *)
    echo "usage: dash open|toggle hub|calendar|media|system|power, dash close" >&2
    exit 1
    ;;
esac
