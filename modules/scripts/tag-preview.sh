# tag-preview: while you hold Super after pressing Super+N (any tag key), a
# card on that monitor with all the tags of every monitor (settings.nix: 1-5
# left, 6-10 right...) and what is open on each: app icons, a window title,
# each monitor's active tag highlighted. Releasing Super hides it.
#
#   tag-preview                  the daemon, for the whole session (river/autostart.nix)
#   tag-preview show OUTPUT T    show the card on OUTPUT, for a key pressed at T (µs; tag.sh)
#   tag-preview hide             Super released (a river -release mapping, keys.nix)
#
# Requests reach the daemon in order through a FIFO. A show for a key
# pressed before the latest release is ignored: on a quick tap the release
# can arrive first, and the card must not stay up. The card is eww's
# `tagpreview` window (dashboard/eww/tagpreview.yuck); river reports tag
# switches through river-tags-watch and windows through `riverctl list-views`
# (a local patch). MONITOR_TAGS ("NAME=1,2,3 NAME=4,5", left to right) comes
# from scripts/default.nix.

state="${XDG_RUNTIME_DIR:-/tmp}/tag-preview"
fifo="$state/requests"

# Client: hand the request to the daemon (if it runs), never block for long
if [ "$#" -gt 0 ]; then
  case "$1" in
    show) line="show ${2:?output} ${3:?press time}" ;;
    hide) line="hide ${EPOCHREALTIME/./}" ;;
    *)
      echo "usage: tag-preview [show OUTPUT TIME | hide]" >&2
      exit 1
      ;;
  esac
  if [ -p "$fifo" ]; then
    # shellcheck disable=SC2016 # expanded by the inner shell, on purpose
    timeout 1 bash -c 'printf "%s\n" "$1" >"$2"' _ "$line" "$fifo" || true
  fi
  exit 0
fi

rm -rf "$state"
mkdir -p "$state"
mkfifo "$fifo"
data="${XDG_DATA_HOME:-$HOME/.local/share}"
icons="$state/icons" # "app id<TAB>icon name", lowercase ids

# Per monitor: its tags as JSON, their bitmask, its focused tags
declare -A owned mask focused
order=()
for entry in $MONITOR_TAGS; do
  name="${entry%%=*}"
  order+=("$name")
  owned[$name]="[${entry#*=}]"
  m=0
  IFS=, read -ra list <<<"${entry#*=}"
  for t in "${list[@]}"; do m=$((m | 1 << (t - 1))); done
  mask[$name]=$m
done
shown=""  # the monitor the card is on, if it is up
released=0 # when Super was last released (µs)

# App id -> icon, from the desktop files: by file name and by
# StartupWMClass (web apps: webapp.NAME). Rebuilt when older than a minute,
# so newly installed apps show up.
index_icons() {
  if [ -s "$icons" ] && [ -z "$(find "$icons" -mmin +1)" ]; then return 0; fi
  local dirs=() dir
  IFS=: read -ra dirs <<<"$data:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
  for dir in "${dirs[@]}"; do
    if [ -d "$dir/applications" ]; then
      find -L "$dir/applications" -name '*.desktop' 2>/dev/null || true
    fi
  done | awk '
    {
      file = $0; id = file; sub(/.*\//, "", id); sub(/\.desktop$/, "", id)
      icon = class = ""; group = 0
      while ((getline line < file) > 0) {
        if (line ~ /^\[/) { group = (line == "[Desktop Entry]"); continue }
        if (group && line ~ /^Icon=/) icon = substr(line, 6)
        if (group && line ~ /^StartupWMClass=/) class = substr(line, 16)
      }
      close(file)
      if (icon == "") next
      print tolower(id) "\t" icon
      if (class != "") print tolower(class) "\t" icon
    }' >"$icons.new"
  mv "$icons.new" "$icons"
}

# eww commands wait only 100 ms for the daemon. When it is slower (busy
# drawing a window), `eww daemon` and a plain `eww open` take it for dead and
# start a second daemon, which steals the socket: windows of the first can
# then never be closed. So: be patient before deciding it is gone, start one
# only if no daemon process exists, and open with --no-daemonize.
running() { eww ping >/dev/null 2>&1; }
ensure_daemon() {
  for _ in $(seq 100); do running && return 0; sleep 0.02; done
  if ! pgrep -u "$(id -u)" -f '^([^ ]*/)?eww daemon' >/dev/null; then
    eww daemon
    for _ in $(seq 100); do running && return 0; sleep 0.02; done
  fi
}

# Every monitor, left to right: [{name, tags, focused}]
monitors() {
  local name sep="" out="["
  for name in "${order[@]}"; do
    out+="$sep{\"name\":\"$name\",\"tags\":${owned[$name]},\"focused\":${focused[$name]:-0}}"
    sep=,
  done
  printf '%s]' "$out"
}

# show OUTPUT: show the card on OUTPUT, closing it elsewhere, or refresh it
show() {
  local here="$1" json
  index_icons
  # Every window: "output<TAB>tags<TAB>focused<TAB>icon<TAB>title"
  json="$(riverctl list-views | awk -F'\t' -v icons="$icons" '
    BEGIN { while ((getline line < icons) > 0) { split(line, f, "\t"); if (!(f[1] in icon)) icon[f[1]] = f[2] } }
    NF >= 3 { # (riverctl ends its output with an empty line)
      id = tolower($4)
      print $1 "\t" $2 "\t" $3 "\t" (id in icon ? icon[id] : "application-x-executable") "\t" $5
    }' | jq -Rnc --arg here "$here" --argjson monitors "$(monitors)" '
      def has($bits; $tag): (($bits / pow(2; $tag - 1)) | floor) % 2 == 1;
      [inputs | split("\t")
        | {output: .[0], tags: (.[1] | tonumber), focused: (.[2] == "1"), icon: .[3], title: (.[4] // "")}] as $views
      | [$monitors[] as $m | {
          name: $m.name,
          here: ($m.name == $here),
          tiles: [$m.tags[] as $t
            | [$views[] | select(.output == $m.name and has(.tags; $t))] as $w
            | {
                key: ($t % 10 | tostring),
                shown: has($m.focused; $t),
                count: ($w | length),
                icons: ($w[:4] | map(.icon)),
                more: ([($w | length) - 4, 0] | max),
                title: (([$w[] | select(.focused)] + $w)[0].title // "")
              }]
        }]')"

  # The session starts it (river/autostart.nix); it may still be coming up
  ensure_daemon
  eww update tagpreview="$json"
  if [ "$shown" != "$here" ]; then
    if [ -n "$shown" ]; then eww close tagpreview >/dev/null 2>&1 || true; fi
    # Counted as shown even if eww reports a timeout: the window may well
    # have opened, and hide must close it
    eww --no-daemonize open tagpreview --screen "$here" >/dev/null 2>&1 || true
    shown="$here"
  fi
}

hide() {
  if [ -n "$shown" ]; then
    eww close tagpreview >/dev/null 2>&1 || true
    shown=""
  fi
}

# One stream, handled in order: tag changes from river, requests from keys
{
  river-tags-watch | while read -r line; do printf 'tags %s\n' "$line"; done &
  while :; do cat "$fifo"; done
} | while read -r kind a b _; do
  case "$kind" in
    tags) # a: output, b: its focused tags
      [ -n "${mask[$a]:-}" ] || continue # a monitor not in settings.nix
      focused[$a]=$b
      # While the card is up (Super held), keep it current
      if [ -n "$shown" ]; then show "$shown" || true; fi
      ;;
    show) # a: output, b: when the key was pressed
      [ "$b" -gt "$released" ] || continue # Super already released
      show "$a" || true
      ;;
    hide) # a: when Super was released
      released=$a
      hide
      ;;
  esac
done
