# zk-paper KEY: start (or reopen) the notes on a paper, filled in from its
# papis entry: title, authors, year, journal, DOI. Behind `zk paper KEY`
# (writing.nix), which provides ZK_NOTEBOOK_DIR.
key="${1:?usage: zk paper CITATION_KEY (as in papis, e.g. li2009)}"
notebook="${ZK_NOTEBOOK_DIR:?run it as: zk paper $key}"
note="$notebook/papers/$key.md"
if [ -e "$note" ]; then
  exec zk edit "$note"
fi

# papis matches the key as a substring (li2009 also finds li2009a): keep the
# exact one. Fields are separated by \x1f, which no title contains and which
# read doesn't merge when a field is empty.
sep=$'\x1f'
info="$(papis list --all \
  --format "{doc[ref]}$sep{doc[title]}$sep{doc[author]}$sep{doc[year]}$sep{doc[journal]}$sep{doc[doi]}" \
  "ref:$key" 2>/dev/null | awk -F "$sep" -v key="$key" '$1 == key { print; exit }')" || info=""

title="$key" details=""
if [ -n "$info" ]; then
  IFS="$sep" read -r _ title authors year journal doi <<<"$info"
  # "Li, Heng and Handsaker, Bob (2009), *Bioinformatics*", then the DOI
  details="$authors"
  if [ -n "$year" ]; then details="$details ($year)"; fi
  if [ -n "$journal" ]; then details="$details, *$journal*"; fi
  if [ -n "$doi" ]; then details="$details"$'\n'"https://doi.org/$doi"; fi
else
  echo "zk paper: '$key' isn't in your papis library; notes with the key only" >&2
fi
# The details go in as the note's {{content}} (templates/paper.md): zk
# splits --extra values at commas, which author lists are full of
printf '%s' "$details" |
  zk new --interactive --no-input --group papers --title "$title" --extra key="$key" "$notebook/papers"
