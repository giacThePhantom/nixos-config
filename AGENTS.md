# Instructions for AI agents

This repository is the user's whole operating system: a NixOS + home-manager
flake for a minimal river desktop. Read README.md first for layout and design.

## Hard rules

- **Never apply the configuration.** No `nixos-rebuild switch|boot|test`, no
  `home-manager switch`, no `sudo`. Build to verify; the user runs `rebuild`.
- **Never touch the live session.** No `pkill`/`killall` by name, no
  `riverctl` against the user's river, no restarting their programs. Test in
  `tools/headless-river`, which only kills processes it started.
- **`git add` new files before building:** flakes ignore untracked files.
- **Check nix's own exit status.** `nix build … | tail` reports `tail`'s
  status; redirect output to a file and test `$?` instead.
- Don't commit unless asked; end commit messages with the attribution line
  your harness specifies.

## Verify a change

```sh
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --no-link 2>build.log; echo $?
```

This also runs shellcheck on every script in `home/scripts/`. To inspect
generated files (river init, foot.ini, eww config...) build
`.#nixosConfigurations.nixos.config.home-manager.users.<user>.home-files` and
look under `.config/`. `.claude/skills/build-and-verify` has the details,
`.claude/skills/headless-river-test` covers runtime testing.

## Conventions

- **Minimal footprint first.** Before adding a package, check what it pulls in
  (`.claude/skills/add-software`). Prefer things already in the closure;
  prefer a home-manager `programs.*` module over a raw package when one exists.
- **No hardcoded identity or hardware** in modules: user, hostname and
  monitors come from `settings.nix` (`settings` argument); monitor geometry and
  tag ownership from `home/monitors.nix` (`monitors` argument).
- **No hardcoded colours or fonts:** use the `colors` / `fonts` arguments
  (`palette.nix`), named after the theme's CSS variables. Note that
  `placeholder` is a Nix builtin, which is why the key is `textPlaceholder`;
  avoid other builtin names (`with colors;` would not shadow them).
- **Shell lives in `home/scripts/NAME.sh`**, registered in
  `home/scripts/default.nix` with its dependencies and any Nix values as
  environment variables. Scripts run under `set -euo pipefail`: beware
  `cmd | grep -q` (SIGPIPE fails the pipe) and commands that may fail.
- **Session programs** start in `home/river/autostart.nix`, after the
  `RIVER_RELOAD` guard; anything before it must be safe to run twice.
- **Keybindings** live in `home/river/keys.nix`; update the table in README.md
  in the same change.
- **One comment on top of every file** saying what it is for; comment the
  why, not the what. Format with `nixfmt`, except `settings.nix`, which stays
  hand-formatted so it reads well; shape data so nixfmt keeps it compact
  (e.g. one string per list item, as in `home/river/rules.nix`).
- **Nerd Font icons:** some editing tools silently drop characters in the
  Unicode private-use area U+E000-U+F8FF. Prefer Material Design icons
  (U+F0000 and up), and check the bytes after writing; insert stubborn ones
  with `printf '\U000F0349'`.

## Gotchas learned the hard way

- river's `swap` is patched to fail when there's no target
  (`system/patches/`); `send-to-output` and `focus-output` still succeed
  silently when there is no monitor in that direction. `river-try` handles
  both (see `home/pkgs/river-tools/river-try.c`).
- River tags are per monitor: after `send-to-output`, focusing that monitor
  focuses its last window, not the moved one, unless the window is visible
  there (hence `-current-tags` and the retagging dance in `tag.sh`).
- eww on Wayland needs an explicit monitor (`--screen NAME`).
- Headless screenshots with the default pixman renderer draw translucent
  windows (foot at alpha 0.95) washed out; use the gles2 renderer.
