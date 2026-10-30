# dvt [NAME [COMPONENT...]]: start a per-project dev environment in the
# current directory (`dvt bio`, `dvt python`, `dvt rust`...); without NAME,
# pick one. The templates are this flake's (`nix flake show
# ~/.config/nixos`): our own, like `bio`, and the-nix-way/dev-templates. Like
# `nix flake init -t`, but from the copies pinned in flake.lock, so it is
# instant and works offline. direnv then loads the shell on `cd`.
#
# Templates with a `use = { NAME = false; # what };` block (bio) are built
# from components: name them (`dvt bio python qc snakemake`) or pick them
# (Tab selects); they can be switched on or off later in flake.nix.
# TEMPLATES ("NAME=PATH NAME=PATH...") comes from scripts/default.nix.

declare -A path
for entry in $TEMPLATES; do path[${entry%%=*}]="${entry#*=}"; done

list() { printf '%s\n' "${!path[@]}" | sort; }

# components FLAKE: "name<TAB>what" for each entry of its `use` block
components() {
  awk '
    /^ *use = \{/ { inside = 1; next }
    inside && /^ *\};/ { exit }
    inside && match($0, /^ *([a-z0-9-]+) = (true|false); *# *(.*)$/, m) { print m[1] "\t" m[3] }
  ' "$1"
}

# dvt --show NAME: the template's flake.nix (the picker's preview)
if [ "${1:-}" = --show ]; then
  cat "${path[${2:-}]:-/dev/null}/flake.nix"
  exit 0
fi

name="${1:-}"
if [ -z "$name" ]; then
  name="$(list | fzf --prompt 'dev environment> ' --preview 'dvt --show {}')" || exit 0
fi
if [ -z "${path[$name]:-}" ]; then
  echo "dvt: no template '$name'. Available:" >&2
  list | column >&2
  exit 1
fi
template="${path[$name]}"

if [ -e flake.nix ]; then
  echo "dvt: there is already a flake.nix here; add packages to it instead" >&2
  exit 1
fi

# Components: from the arguments, else picked
mapfile -t available < <(components "$template/flake.nix")
chosen=("${@:2}")
if [ "${#available[@]}" -gt 0 ]; then
  if [ "${#chosen[@]}" -eq 0 ] && [ -t 0 ]; then
    mapfile -t chosen < <(
      printf '%s\n' "${available[@]}" |
        fzf --multi --delimiter '\t' --tabstop 20 --prompt "$name components> " \
          --header 'Tab: select   Enter: done' || true
    )
    chosen=("${chosen[@]%%$'\t'*}")
  fi
  for c in "${chosen[@]}"; do
    if ! printf '%s\n' "${available[@]%%$'\t'*}" | grep -qxF -- "$c"; then
      echo "dvt: '$name' has no component '$c'. Available:" >&2
      printf '  %s\n' "${available[@]}" | column -t -s $'\t' >&2
      exit 1
    fi
  done
elif [ "${#chosen[@]}" -gt 0 ]; then
  echo "dvt: '$name' has no components to choose" >&2
  exit 1
fi

# Never overwrite existing files (an .envrc), as `nix flake init`
cp -r --update=none --no-preserve=mode "$template/." .
for c in "${chosen[@]}"; do
  sed -i -E "s/^( *)$c = false;/\\1$c = true;/" flake.nix
done

# Flakes ignore untracked files
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # every file the template brought (its scaffold too), as far as git keeps them
  while IFS= read -r file; do
    git add --intent-to-add -- "$file" 2>/dev/null || true
  done < <(cd "$template" && find . -type f -printf '%P\n')
fi
if [ -e .envrc ]; then direnv allow; fi

if [ "${#available[@]}" -gt 0 ] && [ "${#chosen[@]}" -eq 0 ]; then
  echo "dvt: $name environment created with no components: switch them on in flake.nix (use = { ... })."
elif [ "${#chosen[@]}" -gt 0 ]; then
  echo "dvt: $name environment ready with: ${chosen[*]}. Change them in flake.nix (use = { ... })."
else
  echo "dvt: $name environment ready: add packages in flake.nix (devShells.default)."
fi
