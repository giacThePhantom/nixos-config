# Welcome

This is a complete operating system for students and academics in
bioinformatics: a fast, small, keyboard-driven desktop, and the tools research
needs, set up so they just work.

It is built on [NixOS](https://nixos.org). The whole system, from the kernel
to the colour of a window border, is described in one folder of text files,
`~/.config/nixos`. Change a file, run `rebuild`, and the system becomes what
the files say. Nothing drifts, nothing is installed "somewhere", and every
change can be undone from the boot menu.

## The ideas behind it

**The keyboard first.** Everything has a key, and the mouse is optional.
You'll learn five keys on day one and pick up the rest as you go.

**Nothing on screen you didn't ask for.** There is no bar and no desktop
icons. The clock, your calendar, the volume and the system's state live in a
[dashboard](06-dashboard.md) that appears when you call it and disappears when
you're done.

**Small on purpose.** Every program earns its place, and big ones stay
optional. Tools for a specific project live in that project, not in the
system: your RNA-seq analysis gets its own R and Bioconductor, pinned so it
still runs the same in two years, and they're gone when you delete the
project.

**One look.** One palette (`palette.nix`) colours everything: windows,
terminal, launcher, apps, the login screen, the wallpaper and the boot splash.

**Any monitors, ten workspaces.** Workspaces (called *tags*) are shared out
over the monitors you plug in: alone, the laptop has all ten; docked with
two more, tag 1 is on the laptop, 2 to 5 and 6 to 10 on the others.
`Super + 3` always takes you to tag 3, wherever it lives. `Super + D` switches
to presentation or mirror mode and sets each monitor's scale.

## What you get

- A tiling desktop ([river](https://codeberg.org/river/river-classic)): windows
  arrange themselves side by side, no dragging.
- A launcher with categories and web apps, a clipboard history, screenshots.
- A terminal with modern tools, and per-project environments for Python, R,
  Snakemake, Nextflow and the usual bioinformatics tools.
- Easy cluster access: one login per session, remote folders, cloud storage,
  backups, university VPNs.
- References in plain files ([papis](09-research.md#references)), PDF tools,
  fonts that keep Word documents looking right.
- Firefox, Spotify, a calendar, and Steam for the evenings.

Next: [Getting started](02-getting-started.md).
