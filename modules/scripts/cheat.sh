# cheat [NAME]: a cheat sheet (samtools, bcftools, slurm, git, formats...),
# paged; without NAME, pick one. Run outside a terminal (the launcher's
# Cheat sheets menu), it opens itself in a floating one.
# CHEATSHEETS (the folder of NAME.md files) comes from scripts/default.nix.

if [ ! -t 1 ]; then
  exec term --app-id cheatsheet cheat "$@"
fi

name="${1:-}"
if [ -z "$name" ]; then
  name="$(for f in "$CHEATSHEETS"/*.md; do basename "$f" .md; done |
    fzf --prompt 'cheat sheet> ' --preview "bat --color always --style plain $CHEATSHEETS/{}.md")" || exit 0
fi
sheet="$CHEATSHEETS/$name.md"
if [ ! -e "$sheet" ]; then
  echo "cheat: no sheet '$name'. Available:" >&2
  for f in "$CHEATSHEETS"/*.md; do basename "$f" .md; done | column >&2
  exit 1
fi
exec bat --style plain --paging always "$sheet"
