# screenshot region|full: save to ~/Pictures/Screenshots and copy to clipboard
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
if [ "${1:-full}" = region ]; then
  geom="$(slurp -d -b "$SLURP_BG" -c "$SLURP_BORDER")" || exit 0
  grim -g "$geom" "$file"
else
  grim "$file"
fi
wl-copy <"$file"
notify-send -i "$file" "Screenshot" "Copied and saved to $file"
