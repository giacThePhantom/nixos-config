---
name: add-software
description: Add an application, CLI tool, font, service or helper script to this NixOS flake the declarative way, choosing between nixpkgs, home-manager modules, upstream flakes and overrides, and checking how much disk it adds. Use whenever the user wants to install something.
---

# Adding software

## 1. Find it

```sh
nix search nixpkgs <name>                     # packages
```
Home-manager modules: does `programs.<name>` or `services.<name>` exist?
(`man home-configuration.nix`, or grep the home-manager source:
`nix eval --raw --impure --expr '(builtins.getFlake (toString ./.)).inputs.home-manager.outPath'`).

## 2. Pick the place

| Kind | Where |
| --- | --- |
| User app / CLI tool | `home.packages` in the module it belongs to (`home/default.nix` for standalone apps, `terminal.nix` for CLI) |
| Has a home-manager module (config files!) | `programs.<name> = { enable = true; settings = …; }` with `colors`/`fonts` from the palette |
| Needs root, a daemon, kernel or hardware | a `system/*.nix` module (`services.*`, `programs.*`, `hardware.*`) |
| Started with the session | `home/river/autostart.nix`, after the `RIVER_RELOAD` guard, with `&` |
| Not in nixpkgs, upstream has a flake | flake input, see below |
| Small helper command | `home/scripts/NAME.sh` + one line in `home/scripts/default.nix` |

## Upstream flake (e.g. renCal)

```nix
# flake.nix inputs
foo = { url = "github:owner/foo/v1.2.3"; inputs.nixpkgs.follows = "nixpkgs"; };
# a home module
inputs.foo.packages.${pkgs.stdenv.hostPlatform.system}.default
```
Pin a release tag. Prefer `follows` (shares libraries with the system); if
the build then fails on a fixed-output hash ("hash mismatch … got: sha256-…"),
override that hash (see renCal in `home/default.nix`) rather than dropping
`follows`. Only drop `follows` if it genuinely doesn't build.

## Helper scripts

```nix
(script "NAME" [ pkgs.dep1 pkgs.dep2 ] { SOME_VAR = "value from nix"; })
```
Use command names in the `.sh` file, not store paths; shellcheck runs at
build time; scripts run under `set -euo pipefail`.

## 3. Footprint check (before committing to it)

```sh
nix path-info -Sh nixpkgs#<pkg>      # its full closure (upper bound)
```
What it really adds is the part not already in the system. Compare the
system closure before and after (`nix path-info -S` on the built toplevel),
or `nix store diff-closures OLD NEW`. Things to watch: packages pulling a
second toolkit (Qt, GTK4, Electron), every-variant font/icon/cursor packages,
default-on extras (e.g. `services.speechd`, docs). Tell the user the cost when
it is large and offer lighter alternatives.

## 4. Verify

Build with the build-and-verify skill. For GUI apps, check rules in
`home/river/rules.nix` (should it float?) and whether a dashboard panel or
keybinding is wanted.
