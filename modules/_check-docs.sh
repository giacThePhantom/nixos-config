# Run from the repository root by docs.nix: every relative link in the
# Markdown files given (README, AGENTS, the manual, the skills) must point
# to a file that exists and, for "file.md#part", a heading in that file.
# Links in code are skipped; web links aren't checked (no network).

# GitHub's heading anchors: lower case, punctuation dropped, spaces to
# dashes; a repeated heading gets -1, -2...
anchors() {
  awk '/^```/ { code = !code; next }
    !code && /^#+ / {
      h = $0; sub(/^#+ +/, "", h); h = tolower(h)
      gsub(/[^a-z0-9 _-]/, "", h); gsub(/ /, "-", h)
      n = seen[h]++; if (n) h = h "-" n
      print h
    }' "$1"
}

# "LINE TARGET" for each link outside code
links() {
  awk '/^```/ { code = !code; next }
    !code {
      line = $0; gsub(/`[^`]*`/, "", line)
      while (match(line, /\]\([^)]+\)/)) {
        target = substr(line, RSTART + 2, RLENGTH - 3)
        sub(/ +".*"$/, "", target)
        print FNR, target
        line = substr(line, RSTART + RLENGTH)
      }
    }' "$1"
}

bad=0
for file in "$@"; do
  dir="$(dirname "$file")"
  while read -r line target; do
    case "$target" in
      http://* | https://* | mailto:*) continue ;;
    esac
    path="${target%%#*}"
    anchor=""
    if [ "$path" != "$target" ]; then anchor="${target#*#}"; fi
    if [ -z "$path" ]; then dest="$file"; else dest="$dir/$path"; fi
    if [ ! -e "$dest" ]; then
      echo "$file:$line: $target: no such file" >&2
      bad=1
    elif [ -n "$anchor" ] && ! anchors "$dest" | grep -qxF -- "$anchor"; then
      echo "$file:$line: $target: no heading '#$anchor' in $dest" >&2
      bad=1
    fi
  done < <(links "$file")
done
exit "$bad"
