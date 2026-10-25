---
name: headless-river-test
description: Test keybinding scripts, window behaviour, the dashboard or the look of the desktop at runtime in an invisible, isolated river session built from this repo, and take screenshots. Use when a change affects runtime behaviour and building alone does not prove it works.
---

# Runtime testing in a headless river

`tools/headless-river` starts a throwaway river with no visible output, its
own `XDG_RUNTIME_DIR` and this repo's **built** (not applied) configuration.
It never touches the user's session. Never use `pkill`/`killall` by name:
`stop` kills only processes whose environment points at its runtime dir.

```sh
cd ~/.config/nixos && git add -A
tools/headless-river start 2            # two outputs, HEADLESS-1 left of HEADLESS-2
r() { tools/headless-river run "$@"; }
r riverctl spawn 'foot --title A'       # windows are just foot with a title
r river-output                          # focused monitor
r river-try "focus-view right"          # exit 0 if focus moved
tools/headless-river shot /tmp/shot.png # then look at it
tools/headless-river stop               # always, even after failures
```

What it gives you:
- the real river init in reload mode (settings, keys, rules) plus rivercarro;
- every script and package of the home profile on `PATH`;
- `XDG_CONFIG_HOME` pointing at the built configs (eww, foot, fuzzel...).

Session programs (mako, foot server, wallpaper, eww daemon) are not started;
start what the test needs with `r … &`.

## Checking state

- Focused monitor: `r river-output`.
- Focused window title, focused tags, layout: river's status protocol through
  `ristate` (`nix build nixpkgs#ristate`): `r timeout 0.5 ristate -w | tail -1`
  (`-t` tags, `-vt` tags of all windows, `-l` layout). It labels all monitors
  `Unknown`, so combine it with `river-output`.
- Give windows unique titles (`foot --title X`) so focus is observable.

## Gotchas

- Bindings only exist as `riverctl map`s; test the *command* they run (e.g.
  `r focus-dir left`, `r tag focus 32 HEADLESS-2`), substituting HEADLESS-N
  for the real monitor names from settings.nix.
- Tiling needs a layout: `start` sets `default-layout rivercarro`; if windows
  don't tile, check that rivercarro runs.
- Screenshots of translucent windows (foot) look washed out with the default
  pixman renderer: `start 2 gles2` renders like the real GPU session.
- Sockets live in `/tmp/headless-river-$UID`; paths over ~100 chars break
  Wayland, so don't move it under a long directory.
