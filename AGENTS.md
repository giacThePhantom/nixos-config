# Instructions for AI agents

This repository is the user's whole operating system: a NixOS + home-manager
flake for a minimal river desktop. Read README.md first for layout and design;
docs/ is the user manual (docs/README.md), which user-facing changes update.

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

This also runs shellcheck on every script in `modules/scripts/`, and checks
every relative link in README, AGENTS, docs/ and the skills (`modules/docs.nix`)
and the cheat sheets' format. To inspect
generated files (river init, foot.ini, eww config...) build
`.#nixosConfigurations.nixos.config.home-manager.users.<user>.home-files` and
look under `.config/`. `.claude/skills/build-and-verify` has the details,
`.claude/skills/headless-river-test` covers runtime testing.

## Conventions

- **Minimal footprint first.** Before adding a package, check what it pulls in
  (`.claude/skills/add-software`). Prefer things already in the closure;
  prefer a home-manager `programs.*` module over a raw package when one exists.
- **Dendritic modules.** Every `.nix` file under `modules/` is a flake-parts
  module that adds to `flake.modules.nixos.NAME` and/or
  `flake.modules.homeManager.NAME`; group by feature, not by system/home.
  Files that are not modules (hardware config, packages, data) go under a
  `_`-prefixed path, which import-tree skips. A new feature `NAME` must be
  listed in `modules/hosts/nixos/default.nix`. No `specialArgs`: flake-level
  values are read from the outer flake-parts `config`, and `inputs` from the
  outer module arguments (see README, Layout). Inside a NixOS/home module,
  `config` is that module's own config.
- **No hardcoded identity or hardware** in modules: user, hostname and
  monitor layouts come from `settings.nix` (`config.settings`), tag bitmasks
  from `config.monitors` (`modules/flake/meta.nix`). Monitor names, sizes and
  tag ownership are only known at runtime (`modules/scripts/monitors.sh`).
- **No hardcoded colours or fonts:** use `config.colors` / `config.fonts`
  (`palette.nix`), named after the theme's CSS variables. Note that
  `placeholder` is a Nix builtin, which is why the key is `textPlaceholder`;
  avoid other builtin names (`with colors;` would not shadow them).
- **Shell lives in `modules/scripts/NAME.sh`**, registered in
  `modules/scripts/default.nix` with its dependencies and any Nix values as
  environment variables. Scripts run under `set -euo pipefail`: beware
  `cmd | grep -q` (SIGPIPE fails the pipe) and commands that may fail.
- **Session programs** start in `modules/river/autostart.nix`, after the
  `RIVER_RELOAD` guard; anything before it must be safe to run twice.
- **Keybindings** live in `modules/river/keys.nix`; update `docs/04-hotkeys.md`
  (and any chapter that mentions the key) in the same change.
- **One comment on top of every file** saying what it is for; comment the
  why, not the what. Format with `nix fmt`, which skips `settings.nix`: it stays
  hand-formatted so it reads well; shape data so nixfmt keeps it compact
  (e.g. one string per list item, as in `modules/river/rules.nix`).
- **Nerd Font icons:** some editing tools silently drop characters in the
  Unicode private-use area U+E000-U+F8FF. Prefer Material Design icons
  (U+F0000 and up), and check the bytes after writing; insert stubborn ones
  with `printf '\U000F0349'`.

## Gotchas learned the hard way

- river's `swap` is patched to fail when there's no target
  (`modules/river/_patches/`); `send-to-output` and `focus-output` still succeed
  silently when there is no monitor in that direction. `river-try` handles
  both (see `modules/river/_river-tools/river-try.c`).
- River tags are per monitor: after `send-to-output`, focusing that monitor
  focuses its last window, not the moved one, unless the window is visible
  there (hence `-current-tags` and the retagging dance in `tag.sh`).
- eww on Wayland needs an explicit monitor (`--screen NAME`).
- Monitors come and go: `river-outputs-watch` (in `_river-tools`) prints a
  line when heads are added or removed, not on mode/scale changes, so
  `monitors apply` can reconfigure without retriggering itself. Processes it
  starts in the background must not inherit its lock fd (`9>&-`). river has
  no mirroring: mirror mode is a fullscreen wl-mirror per monitor, placed by
  an `output` rule matched on its title.
- Headless screenshots with the default pixman renderer draw translucent
  windows (foot at alpha 0.95) washed out; use the gles2 renderer.
- rofi reads its theme only at runtime and shows an error box on a syntax
  error, so `modules/launcher` checks it in the build. In rasi, comments are
  `/* */` (not `#`), and put one property per line: a string followed by
  another property on the same line is misparsed.
- No protocol says which windows are on which tag: `riverctl list-views`
  (our patch, `modules/river/_patches/river-list-views.patch`) does. The tag
  preview (`modules/scripts/tag-preview.sh`) depends on it.
- Icons by name work everywhere (rofi, eww, notifications); file paths do
  not (eww needs one or the other). Install generated icons into
  `~/.local/share/icons/hicolor/` and refer to them by name, as the web app
  installer does.
- `flake.templates` is declared in `modules/flake/parts.nix` so several
  modules can add project templates; `dvt` reads them all from it.
- Measure before adding: a package's own size hides its closure (nixpkgs'
  visidata pulled ~970 MiB of optional loaders; `data.nix` slims it).
  `nix path-info -r` against the built system, as in add-software.
- Project templates can offer components: a `use = { NAME = false; # what };`
  block in their flake.nix (see `modules/bio/_templates/bio`). `dvt` offers
  each line in its picker and switches the chosen ones to `true`, so keep one
  component per line in that exact shape.
- riverctl drops command output it hasn't flushed (fixed by
  `_patches/riverctl-flush-output.patch`); its output also ends with an
  empty line, so skip blank lines when parsing it.
- Keys can be tested headless with wtype: `wtype -M logo -P Super_L -k 3
  -p Super_L -m logo`. `-M/-m` alone only change the modifier state, so river
  `-release` mappings on Super_L need the `-P/-p` key events too.
- **Neovim's configuration is not in this repository**: `~/.config/nvim` is
  the user's own Lua repository (plugins via `vim.pack`). `modules/editor.nix`
  only supplies tools, the palette (`nixos_palette.lua` on the runtimepath)
  and an assertion that nothing here writes into `~/.config/nvim`.
- **Keep the home clean**: nothing new at the top of `~`. Configure programs
  under `~/.config` (`xdg.configFile`), and if one writes a dotfile, give it
  the environment variable that moves it in `modules/clean-home.nix`. bash's
  files are in `~/.config/bash`, sourced by `/etc/profile.local` and
  `/etc/bashrc.local`.
