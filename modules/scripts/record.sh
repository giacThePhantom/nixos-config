# record [region|screen]: start a screen recording, or stop the one running.
# Recordings go to ~/Videos/Recordings as MP4 (no sound). screen: the
# focused monitor. The recorder is tracked by its PID, never by name. -D: a
# frame at a steady 30 fps (-r) even when nothing moves; with damage tracking
# a still screen sends no frames and the recorder never gets to stop.
state="${XDG_RUNTIME_DIR:-/tmp}/record"
if [ -s "$state" ]; then
  read -r pid file <"$state"
  rm -f "$state"
  if kill -0 "$pid" 2>/dev/null; then
    # wf-recorder finishes the file on SIGTERM (not SIGINT: background jobs
    # of a script start with SIGINT ignored)
    kill -TERM "$pid"
    # Wait until it has (gone, or a zombie its new parent hasn't reaped yet;
    # kill -0 would still succeed on that), at most 5 s
    for _ in $(seq 50); do
      proc="$(awk '{print $3}' "/proc/$pid/stat" 2>/dev/null)" || break
      [ "$proc" != Z ] || break
      sleep 0.1
    done
    notify-send -i video-x-generic "Recording saved" "$file"
    exit 0
  fi
fi

dir="$HOME/Videos/Recordings"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).mp4"
if [ "${1:-region}" = region ]; then
  geom="$(slurp -d -b "$SLURP_BG" -c "$SLURP_BORDER")" || exit 0
  wf-recorder -D -r 30 -g "$geom" -f "$file" >/dev/null 2>&1 &
else
  wf-recorder -D -r 30 -o "$(river-output)" -f "$file" >/dev/null 2>&1 &
fi
printf '%s %s\n' "$!" "$file" >"$state"
notify-send -i media-record "Recording" "Run it again (Super+Print) to stop"
