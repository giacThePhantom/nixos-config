# Navigation

## Workspaces (tags)

You have ten workspaces, called *tags*. Tags 1 to 5 belong to the left
monitor and 6 to 10 to the right one (you can change the split in
`settings.nix`). Each monitor shows one of its own tags at a time.

- `Super + 3` goes to tag 3, on the left monitor. `Super + 8` goes to tag 8,
  on the right monitor, moving your focus there.
- Press the same key again to go back to where you were.
- `Super + Tab` jumps to the previously shown tags.

While you hold `Super` after a tag key, a preview stays on that monitor: all
ten tags, with the icons and a title of what's open on each, and the active
tag of each monitor highlighted. Keep `Super` down and press other numbers to
look around; let go and it disappears.

To move a window instead of yourself:

- `Super + Shift + 3` sends the focused window to tag 3 (on its monitor).
- `Super + Alt + 3` sends it and follows it there.

## Windows

New windows tile: they split the screen with the others, nothing overlaps.
One window is the *master* (the big one on the left); the others stack on the
right.

- `Super + H / J / K / L` moves focus left, down, up, right. At the edge of
  the screen it continues onto the next monitor.
- `Super + Shift + H / J / K / L` moves the window: it swaps places with its
  neighbour, or moves to the next monitor at the edge.
- `Super + M` makes the focused window the master.
- `Super + F` makes it fullscreen, `Super + T` lets it float above the
  others.
- `Super + Q` closes it.

The mouse works too: hold `Super` and drag with the left button to move a
window, with the right button to resize it.

H, J, K and L are the arrows of vim, the editor: left, down, up, right. They
sit under your right hand, so you never reach for the arrow keys.

## Layouts

Each tag remembers its own layout.

- `Super + O` toggles *monocle*: one window at a time, full size;
  `Super + J / K` cycle through them. Good on a laptop screen or for focus.
- `Super + Ctrl + H / L` makes the master narrower or wider.
- `Super + Ctrl + K / J` puts more or fewer windows in the master area.
- `Super + Arrow` puts the master area on that side.
- `Super + = / -` makes the gaps between windows bigger or smaller.

## The scratchpad

``Super + ` `` (the key above Tab) shows a terminal floating in the middle of
the screen, whatever you're doing. Press it again to hide it; it keeps
running in the background with everything you typed. Perfect for a quick
command, a running job's log, or notes.

## Locking and leaving

- `Super + Escape` locks the screen. It also locks itself after 5 minutes
  away, and turns the screens off after 10, but not while sound is
  playing: a video call or a video keeps the screen on.
- `Super + Shift + E` opens the power panel: lock, suspend, log out,
  reboot, shut down.

Next: [Hotkeys](04-hotkeys.md).
