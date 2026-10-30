# screenshot region|full|annotate: save to ~/Pictures/Screenshots and copy to
# the clipboard. annotate: a region, opened in satty to draw arrows, boxes and
# text on it first (Enter copies and saves; its colours: desktop.nix).
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
case "${1:-full}" in
  region)
    geom="$(slurp -d -b "$SLURP_BG" -c "$SLURP_BORDER")" || exit 0
    grim -g "$geom" "$file"
    ;;
  annotate)
    geom="$(slurp -d -b "$SLURP_BG" -c "$SLURP_BORDER")" || exit 0
    grim -g "$geom" - | satty --filename - --output-filename "$file" \
      --copy-command wl-copy --actions-on-enter save-to-clipboard,save-to-file,exit
    exit 0
    ;;
  *) grim "$file" ;;
esac
wl-copy <"$file"
notify-send -i "$file" "Screenshot" "Copied and saved to $file"
