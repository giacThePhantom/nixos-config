# alert COMMAND [ARGS...]: run a command, then a desktop notification with
# its result and how long it took. `alert snakemake --cores 8`.
[ "$#" -gt 0 ] || {
  echo "usage: alert COMMAND [ARGS...]" >&2
  exit 2
}
start="$SECONDS"
status=0
"$@" || status=$?
took=$((SECONDS - start))
took="$((took / 3600))h $((took % 3600 / 60))m $((took % 60))s"
if [ "$status" -eq 0 ]; then
  notify-send -a alert -i dialog-information "Done: $1" "$* (took $took)"
else
  notify-send -a alert -u critical -i dialog-error "Failed ($status): $1" "$* (after $took)"
fi
exit "$status"
