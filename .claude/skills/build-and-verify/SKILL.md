---
name: build-and-verify
description: Build this NixOS/home-manager flake without applying it, inspect the generated config files, diff them against a previous build, and measure closure size. Use after any change to the configuration, before telling the user it works.
---

# Build and verify (never apply)

The user applies changes with `rebuild`. You only build and inspect.

## 1. Build the whole system

```sh
cd ~/.config/nixos
git add -A                                   # flakes ignore untracked files
host=$(nix eval --raw -f settings.nix hostname)
user=$(nix eval --raw -f settings.nix user.name)
nix build ".#nixosConfigurations.$host.config.system.build.toplevel" \
  --no-link --print-out-paths 2>/tmp/build.log
echo "exit=$?"                               # nix's status, not a pipe's
grep -E '^error|SC[0-9]{4}' -A6 /tmp/build.log | head -40
```

Shellcheck runs for every `modules/scripts/*.sh` inside this build; its
findings (`SCxxxx`) make the build fail. So do a broken relative link or
`#heading` in README, AGENTS, docs/ or the skills (`modules/docs.nix`), a
cheat sheet without a `# Title` first line or with lines over 100 columns
(`modules/scripts/default.nix`), and a rofi theme syntax error
(`modules/launcher`). `exit=0` is the bar to report "builds"; anything
else, read the log and fix.

## 2. Inspect what was generated

```sh
hf=$(nix build ".#nixosConfigurations.$host.config.home-manager.users.$user.home-files" \
  --no-link --print-out-paths)
ls "$hf/.config"                 # river/init, foot/foot.ini, rofi, mako, eww, gtk-*/...
bash -n "$(readlink -f "$hf/.config/river/init")"   # syntax check the river init
```

Useful single values: `nix eval ".#nixosConfigurations.$host.config.<option>"`.

## 3. Refactors: prove nothing changed

Before the change, copy `"$hf/.config"` somewhere; after it, diff with store
hashes normalised:

```sh
norm() { sed -E 's|/nix/store/[a-z0-9]{32}-|/nix/store/…-|g' "$1"; }
diff <(norm before/river/init) <(norm after/river/init)
```

For the system: `nix store diff-closures OLD_TOPLEVEL NEW_TOPLEVEL` lists
added/removed/upgraded packages.

## 4. Footprint

```sh
nix path-info -Sh "$toplevel"     # total closure
```

To see what one package costs on its own, see `.claude/skills/add-software`.

## Report

State the exit status, what you inspected, and what the user must do:
`rebuild`, then `Super+Shift+R` (river keys/rules/colours) or log out and in
(session programs, river itself, wallpaper, eww/mako style).
