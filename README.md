# A minimal river desktop on NixOS, for bioinformatics

A NixOS + home-manager flake for a fast, small, keyboard-driven desktop aimed
at students and academics in bioinformatics: the
[river](https://codeberg.org/river/river-classic) tiling compositor, an
on-demand dashboard instead of a bar, one colour palette applied to
everything, and the research basics (per-project environments, cluster
access, data tools, references) without a heavy global install.

## Read the manual

New here? **[The manual](docs/README.md)** takes you from installing to
running an analysis:

1. [Welcome](docs/01-welcome.md) ·
   [Getting started](docs/02-getting-started.md) ·
   [Navigation](docs/03-navigation.md) ·
   [Hotkeys](docs/04-hotkeys.md)
2. [Launcher and web apps](docs/05-launcher.md) ·
   [Dashboard](docs/06-dashboard.md) ·
   [Terminal](docs/07-terminal.md) ·
   [Applications](docs/08-applications.md)
3. [Research tools](docs/09-research.md) ·
   [Projects](docs/10-projects.md) ·
   [Good practice](docs/14-good-practice.md)
4. [Making it yours](docs/11-making-it-yours.md) ·
   [Updates](docs/12-updates.md) ·
   [Troubleshooting](docs/13-troubleshooting.md)

The rest of this page is for people changing the configuration itself.

## Design

- **Minimal footprint.** Every program earns its place; big ones are opt-in
  (`modules/extras/`), and language toolchains live in projects, not in the
  system. No status bar: [eww](https://github.com/elkowar/eww) dashboard
  panels open on demand and poll nothing while hidden. No desktop
  environment, and no systemd *user* session for the desktop: river's init
  script starts the session programs as its own children and they exit with
  it.
- **Per-monitor tags.** Tags 1-5 live on the left monitor, 6-10 on the right
  (`settings.nix`). `Super+N` jumps to the monitor that owns tag N; switching
  shows, while Super is held, a preview of all tags and their windows.
- **Vim keys across monitors.** `Super+H/J/K/L` focus and `Super+Shift+H/J/K/L`
  move windows, continuing onto the next monitor at the screen edge.
- **One palette.** `palette.nix` holds every colour and font; the
  wallpaper is generated from it at build time.
- **Readable, small modules** with a comment on top saying what each is for,
  organised by feature (dendritic, see below).

A few small things are not stock:

- `modules/river/_river-tools/`: tiny C programs talking river's own
  protocols. `river-output` prints the focused monitor; `river-try` runs
  river commands until one of them works (e.g. "focus left, else the monitor
  to the left"); `river-tags-watch` reports each tag switch, for the tag
  preview. Nothing in nixpkgs does these reliably.
- `modules/river/_patches/`: three patches to river.
  `river-swap-report-no-target.patch` makes `swap` report failure when there
  is nothing to swap with (upstream it silently does nothing), so moving a
  window can fall back to the next monitor. `river-list-views.patch` adds
  `riverctl list-views`, which prints every window with its monitor, tags,
  app id and title: no protocol says which windows are on which tag, and the
  tag preview needs it. `riverctl-flush-output.patch` fixes an upstream
  riverctl bug: it exited without flushing its 64-byte output buffer, so
  short outputs vanished and long ones lost their end.

## Layout

The flake follows the [dendritic pattern](https://github.com/mightyiam/dendritic):
every `.nix` file under `modules/` is a [flake-parts](https://flake.parts)
module, imported automatically by [import-tree](https://github.com/vic/import-tree)
(paths starting with `_` are skipped: hardware config, packages, patches). A
file is organised by *feature*, not by NixOS vs home-manager: it adds its
system part to `flake.modules.nixos.NAME` and its user part to
`flake.modules.homeManager.NAME`, and several files can add to the same
`NAME` (`river/` has five). The host then lists the features it runs.

```
settings.nix              who you are, hostname, monitors and their tags  <- edit me
palette.nix               every colour and font                           <- edit me
flake.nix                 inputs only; outputs = everything in modules/
modules/
  hosts/nixos/            this machine: which features, hardware-configuration
  flake/                  plumbing: settings/palette/monitors as options (meta.nix),
                          nixosConfigurations + checks, `nix fmt`
  base.nix                boot, network, locale, sound, the user, Nix
  home.nix                home-manager inside the system build; git, identity
  hardware/               nvidia.nix (driver, VA-API, CUDA cache), storage.nix (drives),
                          bluetooth.nix, laptop.nix (brightness, power modes, touchpad)
  gaming.nix              Steam, Lutris, GameMode
  theme/                  console.nix (TTYs), gtk.nix (GTK/cursor/fonts),
                          apps.nix (renCal, Spotify), _wallpaper.nix
  river/                  session.nix (river patched, greetd login), settings.nix
                          (look, input), keys.nix, rules.nix, autostart.nix,
                          _river-tools/ (river-output, river-try, river-tags-watch), _patches/
  dashboard/eww/          dashboard panels: eww.yuck + one .yuck/.scss per panel,
                          and the tag preview (tagpreview.yuck)
  scripts/                helper commands (*.sh), installed on PATH; _cheatsheets/
                          (the `cheat` sheets for bio tools, SLURM, git...)
  launcher/               Super+D launcher (rofi theme + scripts/launcher.sh), _webapp/
  desktop.nix             notifications (mako), lock (swaylock)
  terminal.nix            foot, bash, starship, zellij, CLI tools
  editor.nix              Neovim: tools and palette only; its config is ~/.config/nvim, its own repo
  apps.nix                renCal, mpv, imv, zathura, default applications
  dev.nix                 dev environments (templates, direnv), comma, gh, Claude Code, herdr
  bio/                    nix-ld, micromamba, seqkit/samtools, the `bio` project template
  data.nix                visidata, duckdb, pueue (job queue), dua, aria2, pigz, hyperfine
  cluster.nix             SSH connection sharing, sshfs, rclone, restic, university VPN
  writing.nix             papis (references), zk (notes), pandoc, PDF tools, Xournal++
  clean-home.nix          bash files in ~/.config/bash, programs told to use the XDG folders
  docs.nix                checks the links in docs/, README, AGENTS (_check-docs.sh), in every build
  passwords.nix           Bitwarden (rbw, rofi-rbw), Super+Shift+P
  extras/                 opt-in: containers, office, libreoffice, igv, pymol, inkscape,
                          backup (nightly restic), syncthing, sioyek (PDFs), accessibility
tools/headless-river      test the desktop in an invisible river session
AGENTS.md, .claude/       instructions and skills for AI coding agents
```

There are no `specialArgs`: `settings.nix` and `palette.nix` are top-level
flake-parts options (`modules/flake/meta.nix`), so a module reads them from
the flake-parts `config` it is defined in:

```nix
{ config, ... }:
let
  inherit (config) colors;   # also: settings, fonts, monitors
in
{
  flake.modules.homeManager.example =
    { pkgs, ... }:
    {
      programs.foo.settings.background = "#${colors.bg}";
    };
}
```

A new file is picked up as soon as it is `git add`ed; a new feature `NAME`
also needs adding to the lists in `modules/hosts/nixos/default.nix`.

## Where the palette is applied


| What | Where it maps `palette.nix` |
| --- | --- |
| Window borders, background, tag overlay | `modules/river/` |
| Dashboard | `modules/dashboard/` (generated `colors.scss`) |
| Launcher, clipboard picker | `modules/launcher/default.nix` (rofi theme, checked at build time) |
| Notifications, lock screen | `modules/desktop.nix` |
| Terminal (foot), prompt, fzf; bat/btop/yazi use the terminal colours | `modules/terminal.nix` |
| Neovim (as `nixos_palette`, read by its own repository) | `modules/editor.nix` |
| GTK 3/4 apps (Lutris, mixer, file pickers, polkit prompt...) | `modules/theme/gtk.nix` (named GTK colours) |
| Firefox | not themed yet: keeps the theme chosen in Firefox |
| renCal, Spotify (Spicetify) | `modules/theme/apps.nix` |
| mpv, imv, zathura | `modules/apps.nix` |
| Wallpaper | `modules/theme/_wallpaper.nix` (generated) |
| TTYs and the login screen | `modules/theme/console.nix`, `modules/river/session.nix` |

Not themed: **Steam** (its client can only be skinned by injecting code into it,
which breaks with Steam updates) and games. **Claude Code** follows the
terminal palette if you pick the ANSI-only dark theme in `/config`.

## Working on this configuration

- Build without applying (also runs shellcheck on every script and checks
  the links in the manual):
  `nix build .#nixosConfigurations.nixos.config.system.build.toplevel --no-link`
- Test the desktop in an invisible session: `tools/headless-river`.
- `nix fmt` formats every Nix file except the hand-formatted `settings.nix`.
- Keys live in `modules/river/keys.nix`; keep [Hotkeys](docs/04-hotkeys.md)
  in sync. User-facing changes belong in the [manual](docs/README.md).
- AI agents: [AGENTS.md](AGENTS.md), and skills in `.claude/skills/`
  (personalize, add software, build and verify, headless testing).
