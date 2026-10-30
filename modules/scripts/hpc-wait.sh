# hpc-wait HOST JOBID...: wait until SLURM jobs on a cluster finish, then a
# desktop notification with each one's final state. Checks once a minute
# over the shared SSH connection (cluster.nix). Leave it running in the
# background: `pueue add -- hpc-wait hpc 123456`.
host="${1:?usage: hpc-wait HOST JOBID...}"
shift
[ "$#" -gt 0 ] || {
  echo "usage: hpc-wait HOST JOBID..." >&2
  exit 2
}
jobs="$(IFS=,; echo "$*")"
err="$(mktemp)"
trap 'rm -f "$err"' EXIT

# Finished when squeue lists none of them, or says it no longer knows them
# (they left its memory). Anything else, ssh failing to connect (255) or
# the scheduler not answering, means ask again later: never give up early.
while :; do
  status=0
  queued="$(ssh "$host" squeue --noheader --jobs "$jobs" 2>"$err")" || status=$?
  if [ "$status" -eq 0 ] && [ -z "$queued" ]; then break; fi
  if [ "$status" -ne 0 ] && grep -q 'Invalid job id' "$err"; then break; fi
  sleep 60
done

# One line per job: "JOBID|STATE|EXITCODE". The accounting database can lag
# behind the queue, and the connection can drop right now: try for ten
# minutes before settling for what we have.
result=""
for _ in 1 2 3 4 5 6 7 8 9 10; do
  result="$(ssh "$host" sacct --noheader --allocations --parsable2 \
    --format JobID,State,ExitCode --jobs "$jobs" 2>/dev/null)" || result=""
  case "$result" in
    "" | *"|RUNNING|"* | *"|PENDING|"* | *"|COMPLETING|"*) sleep 60 ;;
    *) break ;;
  esac
done

if [ -z "$result" ]; then
  notify-send -a hpc-wait -u critical -i dialog-warning "Jobs $jobs on $host finished" \
    "Their results couldn't be read: ssh $host sacct -j $jobs"
  exit 1
fi
while IFS='|' read -r id state code; do
  case "$state" in
    COMPLETED) notify-send -a hpc-wait -i dialog-information "Job $id finished on $host" "$state, exit code $code" ;;
    *) notify-send -a hpc-wait -u critical -i dialog-error "Job $id on $host: $state" "exit code $code" ;;
  esac
done <<<"$result"
