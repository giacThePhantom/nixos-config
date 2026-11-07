# zoom [ARGS]: start Zoom so it can share the screen, and without ~/.zoom.
# Zoom only uses the screen-sharing portal on desktops it knows (GNOME, KDE),
# and with its default xwayland=true it captures through X11, which sees
# nothing of a Wayland desktop. Zoom rewrites zoomus.conf itself, so the two
# settings are put back on every start instead of managing the file.
conf="${XDG_CONFIG_HOME:-$HOME/.config}/zoomus.conf"
if [ -f "$conf" ]; then
  sed -i -e '/^xwayland=/d' -e '/^enableWaylandShare=/d' \
    -e '/^\[General\]$/a xwayland=false\nenableWaylandShare=true' "$conf"
else
  printf '[General]\nxwayland=false\nenableWaylandShare=true\n' >"$conf"
fi

# Zoom keeps its data and logs in ~/.zoom, with no setting to move them. It
# runs in a private view of the home directory (bwrap): every entry is the
# real one, mounted back over an empty one, except ~/.zoom, which is
# ~/.local/share/zoom. Mounting just that over the real home would create an
# empty ~/.zoom for the mount point. An existing ~/.zoom moves there once.
data="${XDG_DATA_HOME:-$HOME/.local/share}/zoom"
if [ -d "$HOME/.zoom" ] && [ ! -e "$data" ]; then
  mkdir -p "${data%/*}"
  mv "$HOME/.zoom" "$data"
fi
mkdir -p "$data"
shopt -s dotglob nullglob
view=()
for entry in "$HOME"/*; do
  if [ "$entry" = "$HOME/.zoom" ]; then
    continue
  elif [ -L "$entry" ]; then
    view+=(--symlink "$(readlink "$entry")" "$entry")
  else
    view+=(--bind "$entry" "$entry")
  fi
done

XDG_CURRENT_DESKTOP=GNOME exec bwrap --dev-bind / / --tmpfs "$HOME" "${view[@]}" \
  --bind "$data" "$HOME/.zoom" -- "$ZOOM" "$@"
