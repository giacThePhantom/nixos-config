# term [ARGS]: open a terminal. footclient attaches to the foot server
# (instant startup); fall back to a standalone foot if it isn't running.
footclient "$@" || exec foot "$@"
