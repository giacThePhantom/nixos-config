# Making it yours

Everything lives in `~/.config/nixos`. After any change: `rebuild`, and
`Super + Shift + R` for keys, rules and colours. New files need `git add`
first.

## You and your monitors: `settings.nix`

Your name, email (used by git), the computer's name, and your monitors from
left to right, each with its tags:

```nix
monitors = [
  { name = "DP-1";     width = 1920; height = 1080; tags = [ 1 2 3 4 5 ]; }
  { name = "HDMI-A-1"; width = 1920; height = 1080; tags = [ 6 7 8 9 10 ]; primary = true; }
];
```

On a laptop, one monitor with all ten tags is fine. The `primary` monitor
shows the dashboard and gets focus at login.

## Keyboard layout

Also in `settings.nix`:

```nix
keyboard = {
  layout = "it";        # or "us,it" for two, with options = "grp:alt_shift_toggle"
  variant = "";         # e.g. "intl" (US with accents), "dvorak"
  options = "";         # e.g. "caps:escape"
};
```

It applies to the desktop and to the text screens, including the login
screen. Names of layouts, variants and options:
`localectl list-x11-keymap-layouts` (and `…-variants it`, `…-options`).

## Laptops

Add `laptop` to both lists in `modules/hosts/nixos/default.nix`: the
brightness keys, the battery and power mode in the System panel, power modes
in *Super + D > System* (performance, balanced, power-saver), and tap to
click and natural scrolling on the touchpad. Closing the lid suspends, and
the screen is locked when you open it. Your laptop's own screen goes in
`settings.nix` like any monitor (usually `eDP-1`).

## A clean home folder

Your home folder holds the standard folders (Documents, Downloads, Music,
Pictures, Videos) and almost nothing else:
settings live in `~/.config`, data in `~/.local/share`, history and logs in
`~/.local/state`, caches in `~/.cache`. Even bash's files are in
`~/.config/bash`. Only three things insist on their own folder: `.ssh`
(SSH keys), `.pki` (certificates, used by browsers) and `.steam`.

Keep your work inside the standard folders too: documents in `~/Documents`,
projects in `~/Projects`. Those two are what the optional backup covers.

After switching to this, a few old folders may still sit in your home. Log
out and back in first (the new locations are read at login; until then,
programs keep writing to the old ones). Background servers outlive logging
out and keep the old settings: run `herdr server stop` and close any zellij
sessions you kept (`zellij ls`), or what runs inside them recreates the old
folders. Then move or delete them once, in a terminal:

```sh
mv ~/.gnupg ~/.local/share/gnupg            # your GPG keys: move, don't delete
cat ~/.bash_history >> ~/.local/state/bash/history   # keep the old history
rm -rf ~/.cargo ~/.nv ~/.pulse-cookie ~/.nix-defexpr ~/.nix-profile ~/.bash_history
rmdir ~/Desktop ~/Public ~/Templates        # unused here; rmdir only removes empty ones
```

(`~/.cargo` is Rust's download cache: it is downloaded again when needed.)

renCal's calendars (`~/caldir`): close renCal, then

```sh
mv ~/caldir ~/.local/share/caldir
sed -i 's|^calendar_dir = .*|calendar_dir = "~/.local/share/caldir"|' ~/.config/caldir/config.toml
```

The dashboard's calendar panel reads the same setting, so it follows.

Claude Code (`~/.claude`, `~/.claude.json`) now looks in `~/.config/claude`.
Close every Claude Code session first (it rewrites `~/.claude.json` while
running), then

```sh
mv ~/.claude ~/.config/claude
mv ~/.claude.json ~/.config/claude/.claude.json
```

Its login, settings, history and per-project memory move with it. If it
asks you to log in again, the second line was missed.

Something new created a dotfile? Many programs accept an environment
variable to use the XDG folders instead: add it to `modules/clean-home.nix`.
[xdg-ninja](https://github.com/b3nj5m1n/xdg-ninja) (`, xdg-ninja`) checks your
home and says how to move each one.

## Colours and fonts: `palette.nix`

Every colour of the system comes from here, named after what it's for: `bg`,
`text`, `accent`... Change `accent` and the window borders, the launcher's
highlight, the prompt, the lock screen and the apps follow. The wallpaper is
generated from the palette too.

## Adding software

1. Find the package on [search.nixos.org](https://search.nixos.org/packages)
   (try it first: `, name`).
2. Add it to the list in `modules/apps.nix` (apps) or `modules/terminal.nix`
   (command-line tools):
   ```nix
   home.packages = [
     pkgs.gimp
   ];
   ```
3. `rebuild`.

Tools for one project belong in that project's `flake.nix` instead (see
[Projects](10-projects.md)), so the system stays small.

## Features on and off

`modules/hosts/nixos/default.nix` lists what this computer runs, one name per
feature: `gaming`, `bio`, `cluster`, `writing`... Remove a name to remove the
feature; add one of the optional apps (`office`, `igv`...) to get it. Each
name is a file (or folder) in `modules/`, with a comment on top saying what
it does.

## Keys

`modules/river/keys.nix`. Each line is a key and what it does:

```nix
"Super W" = "spawn firefox";
"Super+Shift M" = "spawn spotify";
```

`spawn` starts a program. Update [Hotkeys](04-hotkeys.md) when you change
one.

## Windows that should float

Some windows (dialogs, the mixer, picture-in-picture) float instead of tiling.
The list is in `modules/river/rules.nix`. To find a window's name (its
*app id*), run `riverctl list-views` while it's open: the fourth column.

## Programs that start with the desktop

`modules/river/autostart.nix`, after the line that says *Session start only*.
The screen-lock and screens-off timers are there too, and the night light:
colours turn warmer from 20:30 to 07:00 (`wlsunset -s 20:30 -S 07:00`;
`-t 4000` is how warm, lower is warmer).

## The launcher and the dashboard

- A new launcher menu: a `menu_NAME` function in `modules/scripts/launcher.sh`,
  added to `menu_main`.
- A new dashboard panel: see `.claude/skills/personalize/SKILL.md`, *How to
  add a panel*.

## Asking an AI to do it

The repository explains itself to coding agents (`AGENTS.md`, and skills in
`.claude/skills/`). Open Claude Code in `~/.config/nixos` (`cd ~/.config/nixos
&& claude`) and ask: "make the accent green", "add GIMP", "put Firefox on tag
2 at startup". It builds and checks the change; you run `rebuild`.

## How it's organised

For the curious: the layout of `modules/`, how a feature file is written, and
the few non-standard parts are described in the
[README](../README.md#layout).

Next: [Updates](12-updates.md).
