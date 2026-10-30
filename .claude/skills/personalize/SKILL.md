---
name: personalize
description: Change how this desktop looks and behaves - colours/theme, fonts, wallpaper, monitors and their tags, keybindings, window rules, startup programs, dashboard panels, user identity, Qt theming. Use when the user wants the system to look or work differently.
---

# Personalizing the desktop

Find the right file, change it, then verify with the build-and-verify skill
(and headless-river-test for behaviour). Keep the manual (docs/) in sync.

| Change | Where |
| --- | --- |
| User, email, hostname | `settings.nix` |
| Monitors: names, sizes, order, tags | `settings.nix` → `monitors` (derived facts in `modules/flake/meta.nix`) |
| Colours, fonts | `palette.nix` (repo root) |
| GTK/cursor/icon theme | `modules/theme/gtk.nix` |
| Wallpaper | `modules/theme/_wallpaper.nix` (generated from the palette) |
| Keybindings | `modules/river/keys.nix` + `docs/04-hotkeys.md` |
| Floating windows, rules | `modules/river/rules.nix` |
| Startup programs, idle timeouts | `modules/river/autostart.nix` |
| Dashboard panels | `modules/dashboard/eww/` (one .yuck + .scss per panel) |
| Terminal look | `modules/terminal.nix` (`programs.foot.settings`) |
| Launcher, clipboard picker | `modules/launcher/default.nix` (rofi theme, checked at build time) |
| Notifications, lock screen | `modules/desktop.nix` |
| Apps with their own UI (renCal, Spotify) | `modules/theme/apps.nix` |
| TTYs, login screen | `modules/theme/console.nix` (+ tuigreet theme in `modules/river/session.nix`) |

README.md has the full "Where the palette is applied" map. A new app that
draws its own UI gets its palette mapping in `modules/theme/apps.nix`. Check
first whether it can read GTK colours (Lutris does; Firefox does with its
"System theme"), which costs nothing.

## Colours and themes

`palette.nix` is the single source. Keys are named after the theme's CSS
variables (`bg`, `bgCard`, `accent`, `danger`/`dangerText`...). To apply a
new theme, map its colours onto the existing keys; don't rename keys (every
module uses them). Translucent colours (rgba) must be flattened over `bg`
into opaque hex. Check terminal contrast: foreground on background around
10:1 is comfortable, 18:1 felt too harsh to this user. The dashboard SCSS
can still use real rgba (`$glass` etc. in `eww.scss`).

## Monitors and tags

Each entry of `settings.monitors` (left to right) has `name` (connector,
from `wlr-randr`), `width`, `height`, `tags` and optionally `primary = true`
(startup focus, dashboard, scratchpad centring). Every tag 1-10 should belong
to exactly one monitor. Positions are computed from widths.

## Keybindings

`keys.nix` uses `spawn "cmd args"` for programs and plain river commands
otherwise (`man riverctl`). Multi-step logic belongs in a script in
`modules/scripts/` (see add-software for registering one), not in escaped
strings. Test the command in a headless river, update docs/04-hotkeys.md.

## Dashboard panels

Panels live in `modules/dashboard/eww/`: one `NAME.yuck` + `NAME.scss` each,
included/imported from `eww.yuck` / `eww.scss`, which hold the shared widgets
(`card`, `hero`, `section`) and one `defwindow` per panel. To add a panel:

1. `NAME.yuck` with `(defwidget NAME-panel [] (card :title "…" :key "X" (hero …) …))`;
   every `defpoll` gets `:run-while {panel == "NAME"}` so it only runs while shown.
2. Include it and add its `defwindow` in `eww.yuck`; `@import` its scss in `eww.scss`.
3. Add it to `panels` in `modules/river/keys.nix` (global key + menu letter),
   a tile in `hub.yuck`, and a row in docs/04-hotkeys.md and docs/06-dashboard.md.

Data that needs real logic goes in a script (`dash-agenda`, `dash-media` in
`modules/scripts/`) that prints JSON for a `defpoll`. Commands started from a
panel go through `dash-run CMD ARGS`, which closes the panel and spawns CMD
under river. The calendar reads renCal's events with the caldir CLI from
`~/caldir`; `rencal://event?uid=…` links open an event in renCal.

Icons are Nerd Font glyphs: prefer U+F0000+ (Material Design), check they
exist in "Symbols Nerd Font", and insert them with `printf '\U000F00ED'` or
ASCII placeholders replaced afterwards if your editor drops them. Test with
the headless-river skill: `tools/headless-river run dash open NAME`, then
`shot`; give it a fake `HOME` with a sample `~/caldir` rather than real data.

## Re-enabling Qt theming

No Qt apps are installed, so Qt isn't themed (saves ~330 MB). When adding a
Qt app: in `modules/theme/gtk.nix` set
`qt = { enable = true; platformTheme.name = "qtct"; style.name = "Fusion"; }`
and generate `qt6ct/qt6ct.conf` + a colour scheme from `colors`
(commit 1249f61, `home/modules/theme.nix`, has a complete version).
