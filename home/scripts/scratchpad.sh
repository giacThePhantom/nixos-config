# scratchpad: show/hide the scratchpad terminal, starting it on first use.
# It lives on the hidden tag $SCRATCH_TAG (river rules send it there).
if ! lswt -j | jq -e 'any(.toplevels[]; ."app-id" == "scratchpad")' >/dev/null; then
  riverctl spawn 'footclient --app-id scratchpad || foot --app-id scratchpad'
fi
riverctl toggle-focused-tags "$SCRATCH_TAG"
