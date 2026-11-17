# Making it yours

Everything lives in `~/.config/nixos`. After any change: `rebuild`, and
`Super + Shift + R` for keys, rules and colours. New files need `git add`
first.

## You: `settings.nix`

Your name, email (used by git), the computer's name, your keyboard layout
and how tags are shared out over your monitors.

## Monitors

Monitors need no names or sizes: they are found when plugged in and laid
out left to right, the laptop's own screen first (`Super + D` swaps two
external ones). `settings.nix` says which tags each one owns, the laptop's
first, by how many are connected; any other number shares the ten tags out
evenly, and tags left out go to the first monitor:

```nix
monitors = {
  layouts = {
    "1" = [ [ 1 2 3 4 5 6 7 8 9 10 ] ];
    "2" = [ [ 1 2 3 4 5 ] [ 6 7 8 9 10 ] ];
    "3" = [ [ 1 ] [ 2 3 4 5 ] [ 6 7 8 9 10 ] ];
  };
  presentation = [ [ 1 2 ] [ 3 4 5 6 7 8 ] ];   # Super+D > Presentation
  scale = { "eDP-1" = 1.25; };                  # optional: fixed scales
};
```

Scales are chosen from each monitor's pixel density unless `scale` fixes
one, by connector (`eDP-1`, `DP-2`) or by `"make model serial"` as
`wlr-randr` prints them (so a monitor keeps it on any port). A scale picked
in `Super + D` wins over both. The menu's choices are kept in
`~/.local/state/monitors/`; delete that folder to forget them. See
[Navigation](03-navigation.md#monitors) for the layouts.

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

## Home row mods

The `home-row-mods` feature (`modules/hardware/home-row-mods.nix`, on every
keyboard) turns the home row into modifiers when held: `A S D F` are
`Super Alt Ctrl Shift`, mirrored on `J K L ;`. Tapped, they type their letter.

- Use the modifier of one hand with a key of the other: hold `;` and press
  `B` for Firefox, hold `D` and press `L` for `Ctrl + L`.
- With a key of the same hand, or space and the digits, hold a little longer
  (200 ms): hold `A`, wait, press `3`.
- Right after typing another key it is always the letter, so fast typing
  never fires a modifier. Pause briefly before a shortcut.
- The real `Super`, `Alt`, `Ctrl` and `Shift` keys still work.

It works the same on the text screens. Drop `home-row-mods` from
`modules/hosts/nixos/default.nix` to turn it off; the timing is the `hold`
value in its file.

## Laptops

Add `laptop` to both lists in `modules/hosts/nixos/default.nix`: the
brightness keys, the battery and power mode in the System panel, power modes
in *Super + Space > System* (performance, balanced, power-saver), and tap to
click and natural scrolling on the touchpad. Closing the lid suspends, and
the screen is locked when you open it.

## A new drive

Extra drives are listed in `modules/hardware/storage.nix`, each mounted
under `/mnt` the first time you open it. To turn a drive into Linux storage
(**this erases everything on it**):

```sh
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS,MODEL       # find it by size and model
ls -l /dev/disk/by-id/ | grep -v part                    # its stable name (ata-MODEL_SERIAL)
disk=/dev/disk/by-id/ata-MODEL_SERIAL                    # that one, not sdX: letters change
sudo systemctl stop mnt-NAME.automount mnt-NAME.mount    # if it is mounted now
sudo wipefs -a "$disk"-part* "$disk"                     # forget the old filesystem and partitions
printf 'label: gpt\n,,L\n' | sudo sfdisk "$disk"         # one Linux partition, the whole disk
sudo mkfs.ext4 -L NAME "$disk"-part1                     # format it, with a label
```

Then give it an entry in `storage.nix`, with `device =
"/dev/disk/by-label/NAME"`, `fsType = "ext4"` and `options = common`,
`rebuild`, and make it yours once: `ls /mnt/NAME && sudo chown "$USER":users
/mnt/NAME` (a new ext4 drive belongs to root).

Prefer ext4 for anything Linux uses: games, projects, data. Keep NTFS only
for a drive that Windows must read too.

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

renCal's calendars (`~/caldir`): new setups keep them in
`~/.local/share/caldir`; an older one moves once. Close renCal, then

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
highlight, the prompt, the lock screen and the apps follow. The wallpaper
(the EnjoyTheLab logo on the first monitor, the bare gradient on the others),
the lock screen (the logo, which the password ring circles while you type),
the boot splash and fastfetch's logo are generated from the palette too. The
logo is `modules/theme/_branding/wallpaper.svg` (logo and name) and `icon.svg`
(logo alone), with `@logoEnjoy@`-style placeholders where the colours go.

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
