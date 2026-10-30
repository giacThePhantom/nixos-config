# term [ARGS]: open a terminal. footclient attaches to the foot server
# (instant startup); fall back to a standalone foot only if it can't reach
# the server (exit code 220). Any other code is the shell's own: closing the
# window (Super+W) kills the shell, and that must not open a new terminal.
status=0
footclient "$@" || status=$?
if [ "$status" -eq 220 ]; then
  exec foot "$@"
fi
exit "$status"
