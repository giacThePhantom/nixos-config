# dash-media: what's playing, as JSON for the media panel:
#   {status, title, artist, album, art, progress, pos, len}
# Cover art from a URL (Spotify) is downloaded once into $XDG_RUNTIME_DIR.
sep="$(printf '\037')" # field separator that can't appear in titles
fmt="{{status}}$sep{{title}}$sep{{artist}}$sep{{album}}$sep{{mpris:artUrl}}"
fmt="$fmt$sep{{position}}$sep{{mpris:length}}$sep{{duration(position)}}$sep{{duration(mpris:length)}}"

if ! info="$(playerctl metadata --format "$fmt" 2>/dev/null)"; then
  echo '{"status":"Stopped","title":"","artist":"","album":"","art":"","progress":0,"pos":"","len":""}'
  exit 0
fi
IFS="$sep" read -r status title artist album url pos len pos_text len_text <<<"$info"

art=""
case "$url" in
  file://*) art="${url#file://}" ;;
  http*)
    dir="${XDG_RUNTIME_DIR:-/tmp}/dash-art"
    file="$dir/$(printf %s "$url" | md5sum | cut -c1-16)"
    if [ -s "$file" ]; then
      art="$file"
    else
      mkdir -p "$dir"
      # Next poll picks it up
      (curl -sfL --max-time 5 -o "$file.part" "$url" && mv "$file.part" "$file") >/dev/null 2>&1 &
    fi
    ;;
esac

progress=0
if [ -n "$len" ] && [ "$len" -gt 0 ] 2>/dev/null; then progress=$((${pos:-0} * 100 / len)); fi

jq -nc --arg status "$status" --arg title "$title" --arg artist "$artist" --arg album "$album" \
  --arg art "$art" --argjson progress "$progress" --arg pos "$pos_text" --arg len "$len_text" \
  '{$status, $title, $artist, $album, $art, $progress, $pos, $len}'
