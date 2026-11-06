# zoom [ARGS]: start Zoom so it can share the screen. Zoom only uses the
# screen-sharing portal on desktops it knows (GNOME, KDE), and with its
# default xwayland=true it captures through X11, which sees nothing of a
# Wayland desktop. Zoom rewrites zoomus.conf itself, so the two settings are
# put back on every start instead of managing the file.
conf="${XDG_CONFIG_HOME:-$HOME/.config}/zoomus.conf"
if [ -f "$conf" ]; then
  sed -i -e '/^xwayland=/d' -e '/^enableWaylandShare=/d' \
    -e '/^\[General\]$/a xwayland=false\nenableWaylandShare=true' "$conf"
else
  printf '[General]\nxwayland=false\nenableWaylandShare=true\n' >"$conf"
fi
XDG_CURRENT_DESKTOP=GNOME exec "$ZOOM" "$@"
