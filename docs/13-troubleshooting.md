# Troubleshooting

## Something broke after a change or an update

Restart and pick the previous generation in the boot menu: you're back to
the last working system. Then undo the change in `~/.config/nixos` (or
`git checkout flake.lock` after an update) and `rebuild`. See
[Updates](12-updates.md#going-back).

## `rebuild` fails

- **"path … does not exist"** or your new file is ignored: you forgot
  `git add`.
- **An error mentioning a file and line**: that's where the mistake is,
  often a missing `;` or bracket.
- **renCal fails with a "hash mismatch" after `nix flake update`**: copy the
  `got:` hash from the error into `modules/apps.nix`, where the comment says.
- **"Refusing to evaluate package … marked as insecure"**: a package depends
  on something with known security problems; leave it out until it's fixed
  upstream.

To test a change without applying it:

```sh
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --no-link
```

## The desktop

- **What happened?** The desktop's log is `~/.local/state/river.log`.
- **Keys or colours didn't change after `rebuild`**: `Super + Shift + R`.
  The wallpaper, the dashboard's look and notifications need a log out and in.
- **A game or VM eats `Super`**: you're in passthrough mode,
  `Super + F11` leaves it.
- **Sharing your screen in a call does nothing**: the screen dims and waits
  for you to click the monitor to share. It works in Firefox, not in web apps.
- **The brightness keys do nothing** (laptops): log out and in once after
  adding `laptop`, so your account joins the group allowed to change it.
- **A window tiles but should float** (or the reverse): `Super + T` now;
  for always, see [Making it yours](11-making-it-yours.md#windows-that-should-float).

## Hardware

- **The boot splash is blank, or you want to see the boot messages**: press
  `Esc` during boot to switch to the text messages. To turn the splash off,
  set `boot.plymouth.enable = false;` in `modules/theme/boot.nix`.
- **Black screen after a kernel or NVIDIA update**: boot the previous
  generation. The system runs the long-term kernel (`pkgs.linuxPackages` in
  `modules/base.nix`), which the driver supports; very new hardware may
  need `pkgs.linuxPackages_latest` instead.
- **A Windows (NTFS) drive won't mount for writing**: Windows left it "in
  use" (Fast Startup). Turn Fast Startup off in Windows.

- **Bluetooth headphones connect but play nothing**: pick them as the output
  in the mixer (`Super + P`, *Output Devices*).
- **The password window doesn't appear** for `Super + Shift + P`: run
  `rbw unlock` in a terminal once; if it says it isn't registered, see
  [Passwords](05-launcher.md#passwords).

## Projects

- **`cd` into a project does nothing**: run `direnv allow` there (needed
  once, and again after `.envrc` changes).
- **The first `cd` takes long**: it's downloading the environment, and with
  R maybe building packages; only the first time.
- **A downloaded program says "not found" although the file is there**: it
  needs the libraries of a normal Linux; they're provided, so open a new
  terminal after `rebuild`. If it still fails, try it inside `dvt bio`, or
  with micromamba.

## FAQ

**Can I install things with `apt` or `pip install` like on Ubuntu?** Not
system-wide: software comes from `~/.config/nixos` (for you) or a project's
`flake.nix` (for a project). Inside a project, `python -m venv` and
`pip install` work as usual if you really need them.

**Where is the app store?** `Super + Space` for what's installed;
[search.nixos.org](https://search.nixos.org/packages) to find more, `, name`
to try it, [Adding software](11-making-it-yours.md#adding-software) to keep it.

**Can I use another editor?** Yes: add it like any software. A proper editor
setup is coming.

**Is my data safe if I break the system?** Yes. Your files in your home
folder aren't touched by `rebuild` or by rolling back. Back them up anyway:
`restic` (see [Research tools](09-research.md#the-cluster)).

**Where do I ask?** Whoever maintains your copy of this configuration, or
Claude Code in `~/.config/nixos`: it knows this configuration.

Next: [Good practice](14-good-practice.md).
