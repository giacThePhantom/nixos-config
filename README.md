# A minimal river desktop on NixOS

A NixOS + home-manager flake for a fast, small, keyboard-driven desktop:
the [river](https://codeberg.org/river/river-classic) tiling compositor, an
on-demand dashboard instead of a bar, and one colour palette applied to
everything (compositor, terminal, launcher, GTK, lock screen, wallpaper).

## Design

- **Minimal footprint.** Every program earns its place. No status bar:
  [eww](https://github.com/elkowar/eww) dashboard panels (calendar, media,
  system, power) open on demand, Omarchy-style; the daemon starts on first use
  and polls nothing while they are hidden. No desktop environment, no Qt
  theming without Qt apps, and no systemd *user* session:
  river's init script starts the session programs as its own children and
  they exit with it.
- **Per-monitor tags.** Tags 1-5 live on the left monitor, 6-10 on the right
  (configurable). `Super+N` jumps to the monitor that owns tag N.
- **Vim keys across monitors.** `Super+H/J/K/L` focus and `Super+Shift+H/J/K/L`
  move windows, continuing onto the next monitor at the screen edge.
- **One palette.** `palette.nix` holds every colour and font; the
  wallpaper is generated from it at build time.
- **Readable, small modules** with a comment on top saying what each is for.

Two small things are not stock:

- `home/pkgs/river-tools/`: two tiny C programs talking river's own
  protocols. `river-output` prints the focused monitor; `river-try` runs
  river commands until one of them works (e.g. "focus left, else the monitor
  to the left"). Nothing in nixpkgs does either reliably.
- `system/patches/river-swap-report-no-target.patch`: makes river's `swap`
  report failure when there is nothing to swap with (upstream it silently does
  nothing), so moving a window can fall back to the next monitor.

## Layout

```
settings.nix              who you are, hostname, monitors and their tags  <- edit me
palette.nix               every colour and font                           <- edit me
flake.nix                 inputs; wires settings into system and home
hosts/nixos/              machine basics + hardware-configuration.nix
system/
  desktop.nix             river (patched), autologin via greetd, dbus-broker
  nvidia.nix              proprietary NVIDIA driver, VA-API
  storage.nix             secondary drives (automounted)
  gaming.nix              Steam, Lutris, GameMode
  theme.nix               palette for TTYs and the login screen
home/
  default.nix             home-manager entry: packages, git, shared module args
  monitors.nix            facts derived from settings.monitors
  theme/                  GTK/cursor/fonts, wallpaper, apps with own UI (apps.nix)
  river/                  default.nix (look, input), keys.nix, rules.nix, autostart.nix
  dashboard/eww/          dashboard panels: eww.yuck + one .yuck/.scss per panel
  scripts/                helper commands (*.sh), installed on PATH
  desktop.nix             launcher (fuzzel), notifications (mako), lock (swaylock)
  terminal.nix            foot, bash, starship, CLI tools
  apps.nix                mpv, imv, zathura, default applications
  pkgs/river-tools/       river-output, river-try
tools/headless-river      test the desktop in an invisible river session
AGENTS.md, .claude/       instructions and skills for AI coding agents
```

Modules receive these arguments besides the usual `pkgs`, `lib`, `config`:
`settings` (settings.nix), `colors` and `fonts` (palette.nix), `monitors`
(monitors.nix), `inputs` (flake inputs).

## Installing on a new machine

1. Install NixOS normally, enable flakes
   (`nix.settings.experimental-features = [ "nix-command" "flakes" ];`).
2. Clone this repository to `~/.config/nixos`.
3. Replace `hosts/nixos/hardware-configuration.nix` with your
   `/etc/nixos/hardware-configuration.nix`.
4. Edit `settings.nix` (user, hostname, monitors from `wlr-randr` or
   `ls /sys/class/drm`). If you have no NVIDIA GPU remove `./system/nvidia.nix`
   from `flake.nix`; remove or adapt `./system/storage.nix` (your drives' UUIDs:
   `lsblk -f`).
5. `git add -A`, then `sudo nixos-rebuild boot --flake ~/.config/nixos` and reboot.
   You land directly in river.

## Daily use

| Task | How |
| --- | --- |
| Apply changes | `rebuild` (alias for `sudo nixos-rebuild switch --flake ~/.config/nixos`) |
| Reload keys/rules/colours of river | `Super+Shift+R` after `rebuild` |
| Restart session programs (mako, wallpaper, eww...) or river itself | log out (power panel, `Super+Shift+E`) and back in |
| Update everything | `nix flake update` in `~/.config/nixos`, then `rebuild` |
| Roll back | pick an older generation in the boot menu |

New files must be `git add`ed before rebuilding: flakes only see tracked files.

## Keybindings

`Super` is the Windows/Meta key.

| Keys | Action |
| --- | --- |
| `Super+Return` | terminal |
| `Super+D` | app launcher |
| `Super+A` | dashboard menu: pick a panel with its letter (`Esc` closes) |
| `Super+C` | calendar: month + upcoming renCal events (click one to open it) |
| `Super+S` | media: now playing, volume, output, microphone |
| `Super+I` | system: CPU, memory, disk, network |
| ``Super+` `` | scratchpad terminal (show/hide) |
| `Super+W` / `Super+E` / `Super+B` | Firefox / files (yazi) / system monitor (btop) |
| `Super+Shift+M` / `Super+P` | Spotify / volume mixer |
| `Super+V` | clipboard history |
| `Print`, `Super+Shift+S` / `Shift+Print` | screenshot region / full screen (saved and copied) |
| `Super+N` / `Super+Shift+N` | dismiss / restore notification |
| `Super+Escape` | lock |
| `Super+Shift+E` | power panel (lock, suspend, log out, reboot, shut down) |
| `Super+Shift+R` | reload river configuration |
| **Windows** | |
| `Super+H/J/K/L` | focus left/down/up/right, then the next monitor; J/K cycle in monocle |
| `Super+Shift+H/J/K/L` | swap in that direction, or move the window to the next monitor |
| `Super+M` | make master (on the master: swap in the next window) |
| `Super+Q` | close |
| `Super+T` / `Super+F` | toggle floating / fullscreen |
| `Super+Alt+H/J/K/L` | move floating window |
| `Super+Alt+Shift+H/J/K/L` | resize floating window |
| `Super`+drag left / right / middle | move / resize / toggle floating |
| **Layout** (remembered per tag) | |
| `Super+Ctrl+H/L` | master narrower / wider |
| `Super+Ctrl+K/J` | more / fewer windows in the master area |
| `Super+O` | toggle monocle (one window at a time) |
| `Super+Arrows` | master area on top / right / bottom / left |
| `Super+=` / `Super+-` | bigger / smaller gaps |
| **Tags and monitors** | |
| `Super+1..9,0` | go to tag 1-10 (on its monitor); again: back to previous tag |
| `Super+Shift+1..0` | send window to tag |
| `Super+Alt+1..0` | send window to tag and follow it |
| `Super+Ctrl+1..0` | also show tag |
| `Super+Shift+Ctrl+1..0` | also put window on tag |
| `Super+Tab` / `Super+Shift+Tab` | previous tags / all tags of this monitor |
| `Super+,` / `Super+.` | focus previous / next monitor |
| `Super+Shift+,` / `Super+Shift+.` | send window to previous / next monitor |
| `Super+F11` | passthrough mode: all keys go to the window (again to leave) |
| Media keys | volume, mute, play/pause, next, previous (also when locked) |

## Personalizing

| To change | Edit |
| --- | --- |
| Name, email, hostname, monitors, which tags each monitor owns | `settings.nix` |
| Colours, fonts (everywhere) | `palette.nix` |
| Keybindings | `home/river/keys.nix` (and the table above) |
| Floating windows, window rules | `home/river/rules.nix` |
| Programs started with the session, idle/lock timeouts | `home/river/autostart.nix` |
| Dashboard panels | `home/dashboard/eww/` (one `.yuck` + `.scss` per panel), keys in `home/river/keys.nix` |
| Apps | `home/default.nix` (`home.packages`) or the module they belong to |

### Where the palette is applied

| What | Where it maps `palette.nix` |
| --- | --- |
| Window borders, background, tag overlay | `home/river/` |
| Dashboard | `home/dashboard/` (generated `colors.scss`) |
| Launcher, notifications, lock screen | `home/desktop.nix` |
| Terminal (foot), prompt, fzf, Neovim; bat/btop/yazi use the terminal colours | `home/terminal.nix` |
| GTK 3/4 apps (Lutris, mixer, file pickers, polkit prompt...) | `home/theme/default.nix` (named GTK colours) |
| Firefox | not themed yet: keeps the theme chosen in Firefox |
| renCal, Spotify (Spicetify) | `home/theme/apps.nix` |
| mpv, imv, zathura | `home/apps.nix` |
| Wallpaper | `home/theme/wallpaper.nix` (generated) |
| TTYs and the login screen | `system/theme.nix`, `system/desktop.nix` |

Not themed: **Steam** (its client can only be skinned by injecting code into it,
which breaks with Steam updates) and games. **Claude Code** follows the
terminal palette if you pick the ANSI-only dark theme in `/config`.

AI agents: see [AGENTS.md](AGENTS.md); Claude Code also has skills in
`.claude/skills/` (personalize, add software, build and verify, headless testing).

## Gaming

`system/gaming.nix` installs Steam and Lutris (about 1.9 GiB, mostly 32-bit
libraries). Both download their Windows compatibility layers (Proton,
GE-Proton/umu) into your home directory on first use.

- **Steam:** install and play. For Windows-only games: Properties >
  Compatibility > force a Proton version. Add `gamemoderun %command%` to a
  game's launch options for GameMode.
- **EA games (Dragon Age...) through Lutris:** in Lutris press `+` > *Search
  the Lutris website for installers* > **EA App**, install it and log in, then
  install the game from inside the EA App. Lutris adds the EA App as one entry;
  launch games from there. Keep DXVK/VKD3D enabled (default); on NVIDIA also
  enable DXVK-NVAPI/DLSS in the runner options.
- **Bought on Steam?** Dragon Age titles on Steam run through Proton directly;
  Steam starts the EA App by itself when a game needs it.
- **Where to put games:** your home directory or `/mnt/fast` (ext4). Not the
  NTFS drives: Wine prefixes and Proton need Unix permissions and symlinks,
  which NTFS doesn't provide reliably.
- **Games that use the Super key:** `Super+F11` passes all keys to the window.

## Troubleshooting

- **river log:** `~/.local/state/river.log`.
- **Black screen after an NVIDIA or kernel update:** boot the previous
  generation from the boot menu; if the driver doesn't support the newest
  kernel yet, use `pkgs.linuxPackages` in `hosts/nixos/configuration.nix`.
- **An NTFS drive won't mount read-write:** Windows left it "dirty" (Fast
  Startup / hibernation). Disable Fast Startup in Windows.
- **The river patch fails to apply after an update:** upstream changed
  `river/command/view_operations.zig`. Drop the patch in `system/desktop.nix`
  (window moving then stops at the monitor edge) or refresh it.
- **renCal fails with a pnpm hash mismatch after `nix flake update`:** put the
  `got:` hash from the error into the override in `home/default.nix`.
