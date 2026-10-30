# clipboard: pick an entry from the clipboard history and copy it again.
# rofi with the launcher's card theme; cliphist's id column stays hidden.
history="$(cliphist list)"
[ -n "$history" ] || exit 0
lines="$(printf '%s\n' "$history" | wc -l)"
[ "$lines" -le 10 ] || lines=10
printf '%s\n' "$history" |
  rofi -dmenu -i -no-custom -l "$lines" -display-columns 2 -display-column-separator '\t' \
    -mesg "<span letter_spacing='2400' weight='bold' size='9pt'>CLIPBOARD</span>" \
    -theme-str 'entry { placeholder: "Search clipboard history"; } element-icon { enabled: false; }' |
  cliphist decode | wl-copy
