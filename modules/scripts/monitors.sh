# monitors: lay the monitors out whenever they are plugged in or unplugged,
# and switch layout or scale (Super+D, launcher > Setup > Monitors).
#
#   monitors watch                      the daemon, for the whole session (river/autostart.nix)
#   monitors apply                      lay out the connected monitors now
#   monitors mode [auto|presentation|mirror]  print or set the layout
#   monitors scale OUTPUT auto|FACTOR   set a monitor's scale, remembered per monitor
#   monitors swap                       reverse the order of the external monitors
#   monitors list                       "name id scale auto|fixed WxH density-scale", tab-separated
#   monitors primary                    the first monitor (dashboard, wallpaper logo)
#
# Left to right: the laptop's own screen (eDP, LVDS, DSI), then the others
# in the order saved by `swap`, else by connector name. Tags per monitor come
# from settings.nix (SETTINGS, a JSON file from scripts/default.nix: layouts
# by number of monitors, presentation); tags no monitor owns go to the
# first. In mirror mode the first owns them all and the others show it
# through wl-mirror, on the hidden tag MIRROR_TAG. Windows on a tag that
# moved go with it. Scale: the one picked here, else settings.nix (scale),
# else from the pixel density.
#
# A layout chosen for a set of monitors stays while that set is connected
# (a flaky projector cable doesn't undo it) and the next different set
# starts automatic. Runtime state, read by tag.sh, tag-preview.sh, dash.sh:
#   $XDG_RUNTIME_DIR/monitors/layout   "NAME TAGS" left to right, TAGS "1,2,3" or "-" (none)

runtime="${XDG_RUNTIME_DIR:-/tmp}/monitors"
state="${XDG_STATE_HOME:-$HOME/.local/state}/monitors"
mkdir -p "$runtime" "$state"
layout="$runtime/layout"
modefile="$runtime/mode" # the chosen layout, then the monitors it was chosen for
scales="$state/scales"   # "id<TAB>scale": picked in the menu
order="$state/order"     # ids of the external monitors, left to right

# The connected monitors, as wlr-randr sees them
outputs() { wlr-randr --json; }

# Which monitors are connected, as one line (ids sorted)
setkey() {
  jq -r '[.[] | .name + " " + ([.make, .model, .serial] | map(. // "Unknown") | join(" "))] | sort | join("|")' <<<"$1"
}

# The layout in force for these outputs
current_mode() {
  local mode key
  { read -r mode && read -r key; } 2>/dev/null <"$modefile" || return 0
  if [ "$key" = "$(setkey "$1")" ]; then echo "$mode"; fi
}

# plan OUTPUTS MODE: the layout as JSON, left to right: [{name, id,
# internal, scale, fixed, auto, x, y, w, h (logical), tags, mirror, and what
# needs changing}]
plan() {
  local saved='{}' ord='[]'
  if [ -s "$scales" ]; then saved="$(jq -Rn '[inputs | split("\t") | {(.[0]): (.[1] | tonumber)}] | add // {}' <"$scales")"; fi
  if [ -s "$order" ]; then ord="$(jq -Rn '[inputs]' <"$order")"; fi
  jq -c --arg mode "$2" --slurpfile settings "$SETTINGS" --argjson saved "$saved" --argjson order "$ord" '
    # "make model serial" as river names monitors; the connector if all unknown
    def ident: if .make == null and .model == null and .serial == null then .name
      else [.make, .model, .serial] | map(. // "Unknown") | join(" ") end;
    def mode: ((.modes | map(select(.current)))[0] // (.modes | map(select(.preferred)))[0]
      // .modes[0] // {width: 1920, height: 1080});
    # Pixels per inch over 120, in quarters, 1 to 3. No size, or one under
    # 10 inches across (projectors, EDIDs that give only the aspect ratio):
    # 1, it is a guess anyway.
    def density:
      .physical_size as $p
      | if ($p.width * $p.width + $p.height * $p.height) < 250 * 250 then 1
        else (mode.width / ($p.width / 25.4) / 120 * 4 | round) / 4 | [., 1] | max | [., 3] | min
        end;

    $settings[0] as {$layouts, $presentation, scale: $conf}
    | [.[] | . + {id: ident, internal: (.name | test("^(eDP|LVDS|DSI)-"))}] as $all
    | ($all | map(select(.internal)) | sort_by(.name))
      + ($all | map(select(.internal | not)) | sort_by([(.id as $i | $order | index($i)) // 1000, .name]))
    | length as $n
    | (if $mode == "mirror" and $n > 1 then [[range(1; 11)]]
       elif $mode == "presentation" then $presentation
       else $layouts[$n | tostring]
         // [range(0; $n) as $i | [range(1; 11) | select(((. - 1) * $n / 10 | floor) == $i)]]
       end) as $wanted
    # Each tag once, the first monitor taking the ones nobody owns
    | (reduce range(0; $n) as $i ({seen: [], own: []};
         .seen as $seen | (($wanted[$i] // []) | map(select(. >= 1 and . <= 10)) - $seen) as $t
         | .own += [$t] | .seen += $t)) as $r
    | ($r.own | if $n > 0 then .[0] = (.[0] + ([range(1; 11)] - $r.seen) | sort) else . end) as $own
    | [to_entries[] | .key as $i | .value
       | ($saved[.id] // $conf[.name] // $conf[.id]) as $fixed
       | density as $auto
       | ($fixed // $auto) as $scale
       | mode as $m
       | (if (.transform | test("90|270")) then [$m.height, $m.width] else [$m.width, $m.height] end) as $px
       | {name, id, internal, scale: $scale, fixed: ($fixed != null), auto: $auto,
          w: ($px[0] / $scale | floor), h: ($px[1] / $scale | floor),
          tags: $own[$i], mirror: ($mode == "mirror" and $i > 0),
          enabled, hasmode: any(.modes[]; .current), was: {scale, x: .position.x, y: .position.y}}]
    # Side by side, top edges aligned
    | reduce .[] as $o ([]; . + [$o + {x: ((last // {x: 0, w: 0}) | .x + .w), y: 0}])
  ' <<<"$1"
}

# Show the hidden mirror tag on every monitor in PLAN marked mirror, a
# fullscreen wl-mirror of the first monitor on it; stop the others
mirrors() {
  local plan="$1" src wanted out from pid running=""
  src="$(jq -r '.[0].name' <<<"$plan")"
  wanted="$(jq -r '.[] | select(.mirror) | .name' <<<"$plan")"
  : >"$runtime/mirrors.new"
  if [ -s "$runtime/mirrors" ]; then
    while read -r out from pid; do
      [ "$(cat "/proc/$pid/comm" 2>/dev/null)" = wl-mirror ] || continue
      if [ "$from" = "$src" ] && grep -qxF "$out" <<<"$wanted"; then
        echo "$out $from $pid" >>"$runtime/mirrors.new"
        running+=" $out "
      else
        kill "$pid" 2>/dev/null || true
      fi
    done <"$runtime/mirrors"
  fi
  local started=0
  for out in $wanted; do
    [[ "$running" == *" $out "* ]] && continue
    # The window's title tells river where it goes (rules.nix gives the tag).
    # Not holding the lock (fd 9), or the next `monitors` would wait for it.
    riverctl rule-add -app-id at.yrlf.wl_mirror -title "mirror:$out" output "$out"
    setsid wl-mirror --title "mirror:$out" --fullscreen-output "$out" "$src" </dev/null >/dev/null 2>&1 9>&- &
    echo "$out $src $!" >>"$runtime/mirrors.new"
    started=$((started + 1))
  done
  mv "$runtime/mirrors.new" "$runtime/mirrors"
  # A new window takes the focus: wait for them (up to 3 s), so that apply
  # gives it back afterwards
  for _ in $(seq 30); do
    [ "$started" -gt 0 ] || break
    [ "$(riverctl list-views | grep -c $'\tat.yrlf.wl_mirror\t' || true)" -ge "$(wc -w <<<"$wanted")" ] && break
    sleep 0.1
  done
}

# Windows on tags their monitor no longer owns go to the tag's owner (river
# has moved those of an unplugged monitor to another one, tags kept). A
# window stays if any of its tags is owned where it is. Prints "OUTPUT"
# for every monitor whose tags it changed.
redistribute() {
  local -A owner=() count=()
  local name tags list t out vt low key target
  while read -r name tags; do
    [ "$tags" = - ] && continue
    IFS=, read -ra list <<<"$tags"
    for t in "${list[@]}"; do owner[$t]=$name; done
  done <"$layout"
  while IFS=$'\t' read -r out vt _; do
    [ -n "$vt" ] || continue # riverctl ends its output with an empty line
    low=""
    for t in {1..10}; do
      ((vt >> (t - 1) & 1)) || continue
      if [ "${owner[$t]:-}" = "$out" ]; then low="" && break; fi
      [ -n "$low" ] || low=$t
    done
    [ -n "$low" ] && [ -n "${owner[$low]:-}" ] || continue # hidden tags only, or stays
    key="$out $low ${owner[$low]}"
    count[$key]=$((${count[$key]:-0} + 1))
  done < <(riverctl list-views)
  for key in "${!count[@]}"; do
    read -r out low target <<<"$key"
    # Show the tag there, then send its windows one by one (the focused one goes)
    riverctl focus-output "$out"
    riverctl set-focused-tags $((1 << (low - 1)))
    for _ in $(seq "${count[$key]}"); do riverctl send-to-output "$target" || true; done
    echo "$out"
  done
}

apply() { (flock 9; apply_locked) 9>"$runtime/lock"; }

apply_locked() {
  local outs mode plan args prev focus name tags list t own first want touched snapshot
  local -A shown=()
  outs="$(outputs)"
  mode="$(current_mode "$outs")"
  plan="$(plan "$outs" "${mode:-auto}")"
  [ "$(jq length <<<"$plan")" -gt 0 ] || return 0
  focus="$(river-output || true)"

  # One wlr-randr call for every monitor, if anything differs
  mapfile -t args < <(jq -r '
    if any(.[]; (.enabled | not) or (.hasmode | not) or .was != {scale, x, y}) then
      .[] | "--output", .name, "--on", (if .hasmode then empty else "--preferred" end),
        "--scale", (.scale | tostring), "--pos", "\(.x),\(.y)"
    else empty end' <<<"$plan")
  if [ "${#args[@]}" -gt 0 ]; then
    wlr-randr "${args[@]}" || notify-send -u critical "Monitors" "Could not apply the layout"
  fi

  # Each monitor's tags before anything moves (the watcher prints the
  # state at startup, then waits: cut it short)
  snapshot="$(timeout 0.3 river-tags-watch || true)"
  while read -r name t _; do shown[$name]=$t; done <<<"$snapshot"

  prev="$(cat "$layout" 2>/dev/null || true)"
  jq -r '.[] | "\(.name) \(if .mirror or (.tags | length) == 0 then "-"
    else .tags | map(tostring) | join(",") end)"' <<<"$plan" >"$layout.new"
  mv "$layout.new" "$layout"

  mirrors "$plan"
  touched=" $(redistribute | tr '\n' ' ') "

  # Tags with windows, per monitor
  local -A busy=()
  while IFS=$'\t' read -r name t _; do
    if [ -n "$t" ]; then busy[$name]=$((${busy[$name]:-0} | t)); fi
  done < <(riverctl list-views)

  # Each monitor keeps the tags it showed if it still owns one of them, else
  # shows its first tag with windows, or its first; monitors without tags
  # show the (hidden) mirror tag
  while read -r name tags; do
    if [ "$tags" = - ]; then
      want=$MIRROR_TAG
    else
      own=0 first=""
      IFS=, read -ra list <<<"$tags"
      for t in "${list[@]}"; do
        own=$((own | 1 << (t - 1)))
        [ -n "$first" ] || first=$((1 << (t - 1)))
      done
      for t in "${list[@]}"; do
        if ((${busy[$name]:-0} >> (t - 1) & 1)); then first=$((1 << (t - 1))) && break; fi
      done
      want=${shown[$name]:-0}
      ((want & own)) || want=$first
    fi
    if [ "$want" != "${shown[$name]:-}" ] || [[ "$touched" == *" $name "* ]]; then
      riverctl focus-output "$name"
      riverctl set-focused-tags "$want"
    fi
  done <"$layout"

  # Floating windows sized for the first monitor, at its scale
  read -r name w h < <(jq -r '.[0] | "\(.name) \(.w) \(.h)"' <<<"$plan")
  local sw=$((w * 85 / 100 < 1400 ? w * 85 / 100 : 1400)) sh=$((h * 85 / 100 < 800 ? h * 85 / 100 : 800))
  riverctl rule-add -app-id scratchpad dimensions "$sw" "$sh"
  riverctl rule-add -app-id scratchpad position $(((w - sw) / 2)) $(((h - sh) / 2))
  riverctl rule-add -app-id cheatsheet dimensions $((w - 80 < 1100 ? w - 80 : 1100)) $((h - 80 < 900 ? h - 80 : 900))

  # Focus stays where it was, unless the monitors changed: then the first
  if [ "$(cut -d' ' -f1 <<<"$prev")" != "$(cut -d' ' -f1 "$layout")" ] || [ -z "$focus" ] ||
    ! grep -q "^$focus [0-9]" "$layout"; then # gone, or showing a mirror
    focus="$name"
  fi
  riverctl focus-output "$focus"
}

case "${1:-}" in
  watch)
    river-outputs-watch | while read -r _; do
      # A dock brings several monitors at once: wait until they settle
      while read -r -t 1 _; do :; done
      apply || true
    done
    ;;
  apply) apply ;;
  mode)
    outs="$(outputs)"
    case "${2:-}" in
      "") m="$(current_mode "$outs")" && echo "${m:-auto}" ;;
      auto | presentation | mirror)
        printf '%s\n%s\n' "$2" "$(setkey "$outs")" >"$modefile"
        apply
        notify-send -t 2000 "Monitors" "Layout: $2" || true
        ;;
      *) echo "usage: monitors mode [auto|presentation|mirror]" >&2 && exit 1 ;;
    esac
    ;;
  scale)
    out="${2:?usage: monitors scale OUTPUT auto|FACTOR}" value="${3:?usage: monitors scale OUTPUT auto|FACTOR}"
    if [ "$value" != auto ] && ! awk -v s="$value" 'BEGIN { exit !(s + 0 >= 0.5 && s + 0 <= 4) }'; then
      echo "monitors: scale must be auto or 0.5-4" >&2 && exit 1
    fi
    outs="$(outputs)"
    id="$(plan "$outs" auto | jq -r --arg o "$out" '.[] | select(.name == $o) | .id')"
    [ -n "$id" ] || { echo "monitors: no monitor $out" >&2 && exit 1; }
    touch "$scales"
    awk -F'\t' -v id="$id" '$1 != id' "$scales" >"$scales.new"
    if [ "$value" != auto ]; then printf '%s\t%s\n' "$id" "$value" >>"$scales.new"; fi
    mv "$scales.new" "$scales"
    apply
    ;;
  swap)
    # Read the order (in plan) before rewriting it
    ids="$(plan "$(outputs)" auto | jq -r '[.[] | select(.internal | not) | .id] | reverse | .[]')"
    printf '%s\n' "$ids" >"$order"
    apply
    ;;
  list)
    outs="$(outputs)"
    m="$(current_mode "$outs")"
    plan "$outs" "${m:-auto}" | jq -r '.[]
      | [.name, .id, .scale, (if .fixed then "fixed" else "auto" end), "\(.w)x\(.h)", .auto] | @tsv'
    ;;
  primary)
    if [ -s "$layout" ]; then
      awk 'NR == 1 { print $1 }' "$layout"
    else
      plan "$(outputs)" auto | jq -r '.[0].name // empty'
    fi
    ;;
  *)
    echo "usage: monitors watch|apply|mode|scale|swap|list|primary (see the top of monitors.sh)" >&2
    exit 1
    ;;
esac
