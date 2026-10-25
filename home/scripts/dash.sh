# dash open|toggle PANEL | dash close: the dashboard panels, eww windows
# named hub (the menu), calendar, media, system and power. One is open at a
# time, on the primary monitor. While one is open river is in "dashboard"
# mode (letters switch panels, Escape closes), and only that panel's polls run
# (the eww variable `panel`). The eww daemon starts on first use, then stays.

running() { eww ping >/dev/null 2>&1; }
current() { if running; then eww get panel; fi; }

open() {
  if ! running; then
    # Starting the daemon ourselves and polling is ~0.4 s; letting `eww open`
    # auto-start it waits a fixed ~1 s.
    eww daemon
    for _ in $(seq 100); do running && break; sleep 0.02; done
  fi
  shown="$(current)"
  if [ -n "$shown" ]; then eww close "$shown" >/dev/null 2>&1 || true; fi
  eww update panel="$1"
  # Primary monitor; fall back to the first one if it's unplugged
  eww open "$1" --screen "$PRIMARY_OUTPUT" || eww open "$1" --screen 0
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
