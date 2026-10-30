# launcher [MENU]: Super+D. One searchable list: categories on top (Enter
# opens one, Esc goes back), then every app, most used first. Web apps are
# .desktop files written here and run by `webapp` (launcher/_webapp).
# Looks: rofi's theme (launcher/default.nix); entries are Pango markup.
# From scripts/default.nix: KEYS (a file of "keys<TAB>command" lines) and
# MUTED (palette colour of the description line).

data="${XDG_DATA_HOME:-$HOME/.local/share}"
cache="${XDG_CACHE_HOME:-$HOME/.cache}"
usage="$cache/launcher-usage" # "count<TAB>desktop id" lines

# Entries of the menu being built: name, description, icon name, action
N=() D=() I=() A=()
add() { N+=("$1"); D+=("$2"); I+=("$3"); A+=("$4"); }

# The card's small-caps title
title() { printf "<span letter_spacing='2400' weight='bold' size='9pt'>%s</span>" "${1^^}"; }

# show TITLE [PLACEHOLDER [THEME]]: pick one of the entries; sets $choice,
# fails on Esc. THEME: extra rofi theme rules for this menu.
show() {
  local index i n d lines="${#N[@]}"
  [ "$lines" -le 7 ] || lines=7
  index="$(for i in "${!N[@]}"; do
    # Safe inside Pango markup, without a subshell per entry (\& is a
    # literal & in the replacement)
    n="${N[$i]//&/\&amp;}" n="${n//</\&lt;}" n="${n//>/\&gt;}"
    d="${D[$i]//&/\&amp;}" d="${d//</\&lt;}" d="${d//>/\&gt;}"
    printf '<b>%s</b>\n<span size="small" fgcolor="#%s">%s</span>\0icon\x1f%s\x1e' \
      "$n" "$MUTED" "$d" "${I[$i]}"
  done | rofi -dmenu -i -no-custom -format i -sep $'\x1e' -eh 2 -markup-rows -l "$lines" \
    -mesg "$(title "$1")" -theme-str "entry { placeholder: \"${2:-Search}\"; } ${3:-}")" || return 1
  [ -n "$index" ] && [ "$index" -ge 0 ] || return 1
  choice="${A[$index]}"
}

# ask TITLE PLACEHOLDER: one line of input; fails on Esc
ask() {
  # A pencil instead of the search glyph (U+F03EB, Material Design)
  rofi -dmenu -l 0 -mesg "$(title "$1")" -theme-str "entry { placeholder: \"$2\"; }
    textbox-search { content: \"󰏫\"; }
    listview { enabled: false; } counter { enabled: false; }
    textbox-hint { content: \"↵ confirm    esc cancel\"; }" </dev/null
}

# Visible applications as "uses<TAB>name<TAB>icon<TAB>desktop id<TAB>command
# <TAB>description", most used first. Earlier data dirs win, as in the XDG spec.
list_apps() {
  local dirs=() dir
  IFS=: read -ra dirs <<<"$data:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
  for dir in "${dirs[@]}"; do
    if [ -d "$dir/applications" ]; then printf '%s\n' "$dir/applications"; fi
  done | while read -r dir; do
    find -L "$dir" -name '*.desktop' -printf '%H\t%P\n' 2>/dev/null || true
  done | awk -F'\t' -v usage="$usage" '
    BEGIN {
      while ((getline line < usage) > 0) { split(line, u, "\t"); uses[u[2]] = u[1] }
    }
    {
      id = $2; gsub("/", "-", id)
      if (id in seen) next
      seen[id] = 1
      file = $1 "/" $2; name = icon = cmd = generic = comment = ""; term = 0; ok = 1; group = 0
      while ((getline line < file) > 0) {
        if (line ~ /^\[/) { group = (line == "[Desktop Entry]"); continue }
        if (!group || !(eq = index(line, "="))) continue
        k = substr(line, 1, eq - 1); v = substr(line, eq + 1)
        sub(/[ \t]+$/, "", k); sub(/^[ \t]+/, "", v)
        if (k == "Name") name = v
        else if (k == "GenericName") generic = v
        else if (k == "Comment") comment = v
        else if (k == "Icon") icon = v
        else if (k == "Exec") cmd = v
        else if (k == "Terminal") term = (v == "true")
        else if (k == "Type" && v != "Application") ok = 0
        else if ((k == "NoDisplay" || k == "Hidden") && v == "true") ok = 0
        else if (k == "OnlyShowIn" && v !~ /(^|;)river(;|$)/) ok = 0
        else if (k == "NotShowIn" && v ~ /(^|;)river(;|$)/) ok = 0
      }
      close(file)
      if (!ok || name == "" || cmd == "") next
      # Drop field codes (%U, %f...), keep literal %% as %
      gsub(/%%/, "\001", cmd); gsub(/ *%[a-zA-Z]/, "", cmd); gsub(/\001/, "%", cmd)
      if (term) cmd = "term " cmd
      desc = generic != "" ? generic : comment != "" ? comment : "Application"
      gsub(/\t/, " ", desc)
      print (id in uses ? uses[id] : 0) "\t" name "\t" icon "\t" id "\t" cmd "\t" desc
    }' | sort -t$'\t' -k1,1nr -k2,2f
}

# launch DESKTOP-ID<TAB>COMMAND: start an app as a child of river, count the use
launch() {
  local id="${1%%$'\t'*}" cmd="${1#*$'\t'}"
  mkdir -p "$cache"
  touch "$usage"
  awk -F'\t' -v id="$id" 'BEGIN { OFS = "\t" } $2 == id { $1++; found = 1 } { print }
    END { if (!found) print 1, id }' "$usage" >"$usage.new"
  mv "$usage.new" "$usage"
  riverctl spawn "$cmd"
}

# Web app icons live in the icon theme as webapp-NAME
icons_dir="$data/icons/hicolor"
remove_icon() { rm -f "$icons_dir/scalable/apps/webapp-$1.svg" "$icons_dir/256x256/apps/webapp-$1.png"; }

# Desktop files of installed web apps
webapps_dir="$data/applications"
webapp_entries() {
  list_apps | awk -F'\t' '$4 ~ /^webapp-/'
}

menu_main() {
  local _ name icon id cmd desc webapps
  webapps="$(webapp_entries | wc -l)"
  add "Web apps" "$webapps installed · install sites as apps" applications-internet cat:web
  add "Capture" "Screenshots, recordings, clipboard history" applets-screenshooter cat:capture
  add "Dashboard" "Calendar, media, system, power" office-calendar cat:dashboard
  add "Setup" "Audio, network, this configuration" preferences-system cat:setup
  add "System" "Lock, suspend, log out, reboot, shut down" system-shutdown cat:system
  add "Keybindings" "Every shortcut, searchable" preferences-desktop-keyboard-shortcuts cat:keys
  if command -v zk >/dev/null; then
    add "Notes" "Lab notebook, paper notes, any note" accessories-text-editor cat:notes
  fi
  add "Cheat sheets" "samtools, bcftools, SLURM, git, file formats..." help-contents cat:cheats
  if command -v rofi-rbw >/dev/null; then
    add "Passwords" "Copy a password from Bitwarden (Super+Shift+P)" dialog-password "run:rofi-rbw"
  fi
  while IFS=$'\t' read -r _ name icon id cmd desc; do
    add "$name" "$desc" "$icon" "app:$id"$'\t'"$cmd"
  done < <(list_apps)
  show "Launcher" "Search apps and menus"
}

menu_web() {
  local _ name icon id cmd desc
  while IFS=$'\t' read -r _ name icon id cmd desc; do
    add "$name" "${desc#Web app: }" "$icon" "app:$id"$'\t'"$cmd"
  done < <(webapp_entries)
  add "Install web app" "A site in its own window, in this list" list-add web:install
  add "Remove web app" "With its logins and data" list-remove web:remove
  show "Web apps" "Search web apps"
}

menu_notes() {
  add "Today's lab notebook" "What you did, decided, and will do next" x-office-calendar "run:term zk journal"
  add "Find a note" "Search every note by title and text" edit-find "run:term zk edit --interactive"
  add "Recent notes" "Changed in the last two weeks" document-open-recent "run:term zk recent"
  show "Notes"
}

menu_cheats() {
  local file title
  for file in "$CHEATSHEETS"/*.md; do
    title="$(head -1 "$file")"
    add "$(basename "$file" .md)" "${title#\# }" help-contents "run:cheat $(basename "$file" .md)"
  done
  show "Cheat sheets" "Search cheat sheets"
}

menu_capture() {
  add "Screenshot of a region" "Saved to Pictures and copied" applets-screenshooter "run:screenshot region"
  add "Screenshot of the screen" "Saved to Pictures and copied" camera-photo "run:screenshot full"
  add "Annotate a screenshot" "Arrows, boxes, text on a region, then copy" draw-freehand "run:screenshot annotate"
  if [ -s "${XDG_RUNTIME_DIR:-/tmp}/record" ]; then
    add "Stop recording" "Save it to Videos/Recordings" media-playback-stop "run:record"
  else
    add "Record a region" "Video, until you stop it here or with Super+Print" media-record "run:record region"
    add "Record the screen" "This monitor, until you stop it" media-record "run:record screen"
  fi
  add "Clipboard history" "Copy an earlier entry again" edit-paste "run:clipboard"
  show "Capture"
}

menu_dashboard() {
  add "Calendar" "Month and upcoming events" office-calendar "run:dash open calendar"
  add "Media" "Now playing, volume, output, microphone" multimedia-volume-control "run:dash open media"
  add "System" "CPU, memory, disk, network" utilities-system-monitor "run:dash open system"
  add "Power" "Uptime and power actions" system-shutdown "run:dash open power"
  show "Dashboard"
}

menu_setup() {
  add "Audio" "Devices and volume per app" multimedia-volume-control "run:pwvucontrol"
  add "Network" "Wi-Fi and connections (nmtui)" preferences-system-network "run:term nmtui"
  add "Bluetooth" "Pair and connect devices (bluetui)" preferences-system-bluetooth "run:term bluetui"
  add "Configuration" "Edit this system in Neovim" accessories-text-editor "run:term nvim $HOME/.config/nixos"
  add "Reload river" "Keys, rules and colours after a rebuild" view-refresh "run:river-reload"
  if command -v orca >/dev/null; then
    add "Screen reader" "Start Orca (quit: Orca+Q)" preferences-desktop-accessibility "run:orca --replace"
  fi
  show "Setup"
}

menu_system() {
  local mode m
  add "Lock" "Lock the screen" system-lock-screen "run:loginctl lock-session"
  add "Suspend" "Sleep, locked" system-suspend "run:systemctl suspend"
  add "Log out" "Back to the login screen" system-log-out "run:riverctl exit"
  add "Reboot" "Restart the computer" system-reboot "run:systemctl reboot"
  add "Shut down" "Power off" system-shutdown "run:systemctl poweroff"
  # Laptops (power-profiles-daemon): the current mode, and the others
  if mode="$(powerprofilesctl get 2>/dev/null)"; then
    for m in performance balanced power-saver; do
      [ "$m" = "$mode" ] || add "Power mode: $m" "Now: $mode" battery "run:powerprofilesctl set $m"
    done
  fi
  show "System"
}

menu_keys() {
  local keys cmd
  while IFS=$'\t' read -r keys cmd; do
    add "$keys" "$cmd" "" none
  done <"$KEYS"
  show "Keybindings" "Search keys or actions" "element-icon { enabled: false; }"
}

# Sites answer curl's default user agent with stripped-down pages
browser_ua="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"

# page_icons URL: icon addresses for a page, best first: the icons it
# declares (<link rel="icon">, apple-touch-icon...), SVG first, then by size;
# then the conventional /apple-touch-icon.png and /favicon.ico
page_icons() {
  local page final origin base
  page="$(mktemp)"
  final="$(curl -fsL --max-time 10 --max-filesize 3000000 -A "$browser_ua" \
    -o "$page" -w '%{url_effective}' "$1")" || final="$1"
  [[ $final =~ ^(https?://[^/]+) ]] && origin="${BASH_REMATCH[1]}" || origin="$1"
  # Relative addresses resolve against the page's directory
  base="${final%%[?#]*}"
  if [ "$base" = "$origin" ]; then base="$origin/"; else base="${base%/*}/"; fi

  { tr '\n\r' '  ' <"$page" | grep -oiE '<link[^>]*>' || true; } | awk -v origin="$origin" -v base="$base" '
    # attr NAME: the value of an attribute of the current tag, quoted or not
    function attr(name, s) {
      if (match(low, name "=[\"\047][^\"\047]*")) {
        s = substr($0, RSTART, RLENGTH); sub(/^[^=]*=["\047]/, "", s); return s
      }
      if (match(low, name "=[^ >]+")) {
        s = substr($0, RSTART, RLENGTH); sub(/^[^=]*=/, "", s); return s
      }
      return ""
    }
    {
      low = tolower($0)
      rel = tolower(attr("rel")); href = attr("href")
      # mask-icon: a one-colour silhouette for Safari tabs
      if (rel !~ /icon/ || rel ~ /mask-icon/ || href == "" || href ~ /^data:/) next
      gsub(/&amp;/, "\\&", href)
      if (href ~ /\.svg([?#]|$)/ || tolower(attr("type")) ~ /svg/) size = 10000
      else if (match(attr("sizes"), /[0-9]+/)) size = substr(attr("sizes"), RSTART, RLENGTH) + 0
      else if (rel ~ /apple-touch/) size = 180
      else size = 16
      if (href ~ /^https?:/) url = href
      else if (href ~ /^\/\//) url = "https:" href
      else if (href ~ /^\//) url = origin href
      else url = base href
      print size "\t" url
    }' | sort -t$'\t' -k1,1nr | cut -f2
  printf '%s\n' "$origin/apple-touch-icon.png" "$origin/favicon.ico"
  rm -f "$page"
}

# fetch_icon DEST URL...: download the first URL that is really a PNG or SVG
# (what rofi and notifications draw) to DEST.png/.svg and print its path
fetch_icon() {
  local dest="$1" url tmp start
  shift
  tmp="$(mktemp)"
  for url in "$@"; do
    curl -fsL --max-time 10 --max-filesize 3000000 -A "$browser_ua" -o "$tmp" "$url" || continue
    # By content: error pages often come back as HTML with status 200, and
    # many favicon.ico files are PNGs
    start="$(head -c 256 "$tmp" | tr -d '\0')"
    if [ "${start:1:3}" = PNG ]; then
      chmod 644 "$tmp" && mv "$tmp" "$dest.png" && echo "$dest.png" && return 0
    elif [[ $start =~ ^[[:space:]]*\<(\?xml|svg) ]]; then
      chmod 644 "$tmp" && mv "$tmp" "$dest.svg" && echo "$dest.svg" && return 0
    fi
  done
  rm -f "$tmp"
  return 1
}

web_install() {
  local name url slug dir icon fetched themed given note quoted candidates=()
  name="$(ask "New web app: name" "e.g. WhatsApp")" && [ -n "$name" ] || return 0
  url="$(ask "$name: address" "e.g. web.whatsapp.com")" && [ -n "$url" ] || return 0
  case "$url" in http://* | https://*) ;; *) url="https://$url" ;; esac

  # a-z, 0-9 and '-', starting with a letter: webapp's NAME
  slug="$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-')"
  slug="${slug#-}" slug="${slug%-}"
  case "$slug" in [a-z]*) ;; *) slug="app-$slug" ;; esac
  dir="$data/webapps/$slug"
  mkdir -p "$dir" "$webapps_dir"
  remove_icon "$slug"

  # The icon: the site's own, else dashboard-icons by name; only if neither
  # exists, ask for one
  note="$(notify-send -p -i applications-internet "Installing $name" "Looking for its icon…")"
  mapfile -t candidates < <(page_icons "$url")
  candidates+=(
    "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/$slug.svg"
    "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/$slug.png"
  )
  if ! fetched="$(fetch_icon "$dir/icon" "${candidates[@]}")"; then
    given="$(ask "$name: icon" "None found: a PNG or SVG address, or Enter to skip")" || given=""
    if [ -z "$given" ] || ! fetched="$(fetch_icon "$dir/icon" "$given")"; then
      fetched=""
    fi
  fi
  # Into the icon theme as webapp-NAME, so everything that shows icons by
  # name finds it (launcher, notifications, the tag preview)
  icon=applications-internet
  if [ -n "$fetched" ]; then
    icon="webapp-$slug"
    case "$fetched" in
      *.svg) themed="$icons_dir/scalable/apps/$icon.svg" ;;
      *) themed="$icons_dir/256x256/apps/$icon.png" ;;
    esac
    mkdir -p "${themed%/*}"
    mv "$fetched" "$themed"
  fi

  # Characters the .desktop Exec syntax treats specially, as URL escapes
  quoted="${url//\\/%5C}" quoted="${quoted//\"/%22}" quoted="${quoted//\`/%60}" quoted="${quoted//\$/%24}"
  quoted="${quoted//%/%%}"
  cat >"$webapps_dir/webapp-$slug.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=$name
Comment=Web app: ${url#https://}
Exec=webapp $slug "$quoted"
Icon=$icon
StartupWMClass=webapp.$slug
Categories=Network;WebBrowser;
DESKTOP
  notify-send -r "$note" -i "$icon" "Web app installed" "$name is in the launcher (Super+D)"
}

web_remove() {
  local _ name icon id cmd desc slug
  while IFS=$'\t' read -r _ name icon id cmd desc; do
    add "$name" "${desc#Web app: }" "$icon" "$id"
  done < <(webapp_entries)
  if [ "${#N[@]}" -eq 0 ]; then
    notify-send "No web apps installed" "Install one from Super+D > Web apps"
    return 0
  fi
  show "Remove a web app" "Search web apps" || return 0
  id="$choice"
  slug="${id#webapp-}" slug="${slug%.desktop}"
  N=() D=() I=() A=()
  add "Remove $slug" "Its window, icon, logins and data" edit-delete yes
  add "Keep it" "Back to the launcher" go-previous no
  show "Remove $slug?" "" || return 0
  [ "$choice" = yes ] || return 0
  rm -f "$webapps_dir/$id"
  rm -rf "${data:?}/webapps/$slug" "${cache:?}/webapps/$slug"
  remove_icon "$slug"
  notify-send "Web app removed" "$slug"
}

menu="${1:-main}"
while :; do
  N=() D=() I=() A=() choice=""
  if ! "menu_$menu"; then
    # Esc: back to the main list, or close it
    [ "$menu" = main ] && exit 0
    menu=main
    continue
  fi
  case "$choice" in
    cat:*) menu="${choice#cat:}" ;;
    app:*) launch "${choice#app:}" && exit 0 ;;
    run:*) riverctl spawn "${choice#run:}" && exit 0 ;;
    web:install) web_install && exit 0 ;;
    web:remove) web_remove && exit 0 ;;
    *) ;; # informational entries (keybindings): stay
  esac
done
