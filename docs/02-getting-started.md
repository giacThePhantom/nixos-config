# Getting started

## Installing

You need a computer with NixOS installed (the
[graphical installer](https://nixos.org/download/) is fine) and about 30
minutes.

1. In the installed system, enable flakes: add
   `nix.settings.experimental-features = [ "nix-command" "flakes" ];` to
   `/etc/nixos/configuration.nix` and run `sudo nixos-rebuild switch`.
2. Get this configuration:
   ```sh
   git clone <this repository> ~/.config/nixos
   cd ~/.config/nixos
   ```
3. Use your machine's hardware description:
   ```sh
   cp /etc/nixos/hardware-configuration.nix modules/hosts/nixos/_hardware-configuration.nix
   ```
4. Make it yours: edit `settings.nix`. Your login name, full name, email,
   the computer's name, your keyboard layout (`us`, `it`, `de`...), and your
   monitors from left to right (their names: `ls /sys/class/drm`, e.g.
   `card1-DP-1` is `DP-1`; a laptop's own screen is usually `eDP-1`).
5. Tell it what your machine has, in `modules/hosts/nixos/default.nix`:
   remove `nvidia` if you have no NVIDIA graphics card, and `storage` (it
   mounts the author's extra drives; see `modules/hardware/storage.nix` to
   mount yours). On a laptop, add `laptop` to both lists: brightness keys,
   battery, power modes, touchpad.
6. Build it and restart:
   ```sh
   git add -A
   sudo nixos-rebuild boot --flake ~/.config/nixos
   reboot
   ```

You land straight on the desktop: you are logged in automatically at boot,
and the screen locks itself when you step away. After logging out you get a
login screen.

> `git add` matters: the system only sees files git knows about. Every time
> you create a new file in `~/.config/nixos`, `git add` it before `rebuild`.

## Your first five keys

`Super` is the Windows key.

| Keys | What |
| --- | --- |
| `Super + Return` | a terminal |
| `Super + Space` | the launcher: every app, and menus for everything else |
| `Super + W` | close the window |
| `Super + 1` … `Super + 0` | go to workspace 1 … 10 |
| `Super + A` | the dashboard: calendar, media, system, power |

That's enough to work. When you wonder "is there a key for this?", open
*Super + Space > Keybindings* and type what you're looking for.

## Your first ten minutes

1. **Connect to the internet.** Wired works by itself. For Wi-Fi:
   *Super + Space > Setup > Network*, then *Activate a connection*.
2. **Open Firefox** with `Super + B`, and sign in to what you use.
   Bluetooth headphones or mouse: *Super + Space > Setup > Bluetooth*.
3. **Install your web apps** (mail, chat, calendar...): *Super + Space > Web
   apps > Install web app*. Each becomes an app with its own window and icon.
4. **Set up your cluster login** (if you have one): see
   [Research tools](09-research.md#the-cluster).
5. **Try the launcher's search**: `Super + Space`, type `fire`, `Enter`.

## Changing the system

The system is the files in `~/.config/nixos`. To change it:

1. Edit a file (the [Making it yours](11-making-it-yours.md) chapter says
   which).
2. Run `rebuild` in a terminal. It asks for your password and takes from a
   few seconds to a few minutes.
3. If you changed keys, window rules or colours: `Super + Shift + R` reloads
   them. Some things (the wallpaper, the dashboard's look) need a log out
   and in: *Super + Shift + E > Log out*.

If a change breaks something, restart and pick the previous version in the
boot menu. Nothing is ever lost.

Next: [Navigation](03-navigation.md).
