# Launcher, web apps, capture

## The launcher

`Super + D` opens one list with everything: menus at the top, then every app,
the ones you use most first. Start typing to filter (`fire` finds Firefox),
`Enter` to open, `Esc` to go back or close.

The menus:

| Menu | What's in it |
| --- | --- |
| *Web apps* | your web apps, and *Install* / *Remove web app* |
| *Capture* | screenshots (plain or annotated), screen recordings, clipboard history |
| *Dashboard* | the calendar, media, system and power panels |
| *Setup* | sound devices, network and Wi-Fi, Bluetooth, edit this configuration, reload |
| *System* | lock, suspend, log out, reboot, shut down; on laptops, power modes |
| *Passwords* | your Bitwarden passwords (see below) |
| *Notes* | today's journal, find a note, recent notes (see [Research tools](09-research.md#notes)) |
| *Cheat sheets* | the commands you keep looking up: samtools, bcftools, bedtools, seqkit, file formats, SLURM, Snakemake, Nextflow, git, micromamba, moving data, Neovim, bash |
| *Keybindings* | every key, searchable: type "screenshot" or "Super+M" |

Each menu is searchable too, and `Esc` brings you back to the main list.

## Web apps

Gmail, WhatsApp, Teams, Notion, your university's portal: anything you use in
a browser tab can become an app, with its own window, its own icon in the
launcher, and its own place in your workspaces.

To install one: *Super + D > Web apps > Install web app*. Type a name
(`WhatsApp`) and an address (`web.whatsapp.com`), and that's it. The icon is
found by itself: the site's own, or a matching one from
[dashboard-icons](https://github.com/homarr-labs/dashboard-icons). Only if
neither exists will it ask you for an icon address.

What to know:

- Each web app keeps its own logins, separate from Firefox and from the
  other web apps.
- Opening it again brings the open window forward instead of starting a
  second one.
- Links that would open a new tab open in Firefox.
- Notifications work; camera, microphone and location are blocked. For video
  calls, use Firefox.
- It runs on WebKit, the engine of Safari. The rare site that only supports
  Chrome may complain.
- *Remove web app* deletes it, including its logins.

Keys inside a web app: `Ctrl + R` reloads, `Alt + Left / Right` go back and
forward, `Ctrl + = / - / 0` zoom, `Ctrl + L` copies the page's address.

## Screenshots, recordings, clipboard

- `Print` (or `Super + Shift + S`) lets you select a region; `Shift + Print`
  takes the whole screen. Screenshots are saved in `~/Pictures/Screenshots`
  and copied, ready to paste.
- `Ctrl + Print` selects a region and opens it for annotating: arrows,
  boxes, text, highlights, a blur for private details, in the system's
  colours. `Enter` copies and saves it.
- `Super + Print` records a region of the screen as a video (no sound);
  press it again to stop. *Super + D > Capture > Record the screen* records
  the whole monitor. Recordings go to `~/Videos/Recordings`.
- `Super + V` shows everything you copied recently; pick one to copy it
  again.

## Passwords

`Super + Shift + P` searches your [Bitwarden](https://bitwarden.com) vault
and copies the password you pick; the clipboard is cleared after 30 seconds.
The first time, or after an hour, a small window asks for your master
password.

Setting it up, once, in a terminal:

```sh
rbw register     # only for Bitwarden's cloud: it asks for an API key, from
                 # the web vault: Settings > Security > Keys > API key
rbw sync         # download your vault (encrypted)
```

rbw uses your email from `settings.nix`; if your Bitwarden account uses
another, or you run your own Vaultwarden server, change it in
`modules/passwords.nix`. `rbw get NAME` prints a password in scripts.

## Sharing your screen

In a video call in Firefox (Meet, Teams, Zoom; web apps can't share or use
the camera), *Share screen* asks which monitor: the screen dims, click the
one to share. Windows can't be shared one by one, only whole monitors.

The Zoom app shares the same way. Start it from the menu or with `zoom`,
which sets it up for this: its own sharing settings don't work here.

Next: [Dashboard](06-dashboard.md).
