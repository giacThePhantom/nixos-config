# dash-run CMD [ARGS]: close the dashboard, then launch CMD as a child of
# river. Arguments are quoted, so URLs with & or ? pass through intact.
dash close
riverctl spawn "$(printf '%q ' "$@")"
