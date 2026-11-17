# Hotkeys

`Super` is the Windows key. This page lists every key; inside the system,
*Super + Space > Keybindings* has the same list, searchable, read from the live
configuration.

With home row mods (on by default), holding `A S D F` or `J K L ;` also gives
`Super Alt Ctrl Shift`: see [Making it yours](11-making-it-yours.md#home-row-mods).

## Apps

| Keys | What |
| --- | --- |
| `Super + Return` | terminal |
| `Super + Alt + Return` | terminal with zellij (panes, sessions; [its keys](07-terminal.md#zellij)) |
| `Super + Ctrl + Return` | terminal with herdr (a workspace for AI coding agents; [its keys](07-terminal.md#herdr)) |
| ``Super + ` `` | scratchpad terminal: show / hide |
| `Super + Space` | launcher: apps, web apps and menus (`Esc` goes back) |
| `Super + B` | Firefox |
| `Super + E` | files (Thunar) |
| `Super + Alt + E` | files in the terminal (lf) |
| `Super + Shift + M` | Spotify |
| `Super + P` | volume mixer |

## Dashboard

| Keys | What |
| --- | --- |
| `Super + A` | dashboard menu; then a panel's letter opens it |
| `Super + C` | calendar |
| `Super + S` | media and sound |
| `Super + I` | system |
| `Super + Shift + E` | power: lock, suspend, log out, reboot, shut down |
| `Esc` | close the dashboard |

## Everyday

| Keys | What |
| --- | --- |
| `Super + V` | clipboard history |
| `Super + Shift + V` | university VPN: connect in a terminal (`Ctrl + C` disconnects, `Super + W` closes it) |
| `Print` or `Super + Shift + S` | screenshot of a region (saved and copied) |
| `Shift + Print` | screenshot of the whole screen |
| `Ctrl + Print` | screenshot of a region to annotate (arrows, boxes, text), then copy |
| `Super + Print` | record a region of the screen; again to stop (saved in `~/Videos/Recordings`) |
| `Super + Shift + P` | passwords: find one, copy it (cleared after 30 s) |
| `Super + N` / `Super + Shift + N` | dismiss / bring back a notification |
| `Super + Control + N` | do not disturb on/off: notifications wait until it's off |
| `Super + Escape` | lock the screen |
| `Super + Control + Escape` | keep the screen on (no lock, no screens off) / back to normal |
| `Super + Shift + R` | reload keys, window rules and colours (after `rebuild`) |
| Media keys | volume, mute, play/pause, next, previous (also when locked) |
| Brightness keys | screen brightness, on laptops (also when locked) |

## Windows

| Keys | What |
| --- | --- |
| `Super + H / J / K / L` | focus left / down / up / right, then the next monitor |
| `Super + Shift + H / J / K / L` | move the window that way, then to the next monitor |
| `Super + M` | make it the master (on the master: swap in the next window) |
| `Super + W` | close |
| `Super + F` | fullscreen |
| `Super + T` | floating |
| `Super + Alt + H / J / K / L` | move a floating window |
| `Super + Alt + Shift + H / J / K / L` | resize a floating window |
| `Super` + left drag / right drag / middle click | move / resize / float |

## Layout (each tag remembers its own)

| Keys | What |
| --- | --- |
| `Super + O` | monocle (one window at a time) on / off |
| `Super + Ctrl + H / L` | master area narrower / wider |
| `Super + Ctrl + K / J` | more / fewer windows in the master area |
| `Super + Arrow` | master area on top / right / bottom / left |
| `Super + =` / `Super + -` | bigger / smaller gaps |

## Tags and monitors

| Keys | What |
| --- | --- |
| `Super + 1` … `Super + 0` | go to tag 1 … 10 (on its monitor); again: back. Hold `Super` to keep the tag preview up |
| `Super + Shift + 1` … `0` | send the window to that tag |
| `Super + Alt + 1` … `0` | send the window there and follow it |
| `Super + Ctrl + 1` … `0` | also show that tag here |
| `Super + Shift + Ctrl + 1` … `0` | also put the window on that tag |
| `Super + Tab` | back to the previous tags |
| `Super + Shift + Tab` | show all tags of this monitor at once |
| `Super + ,` / `Super + .` | focus the previous / next monitor |
| `Super + Shift + ,` / `Super + Shift + .` | send the window to the previous / next monitor |
| `Super + D`, display key | monitors: automatic, presentation or mirror layout, scale of each, order |
| `Super + F11` | passthrough: every key goes to the window (VMs, games); again to leave |

## Accessibility (optional `accessibility` feature)

| Keys | What |
| --- | --- |
| `Super + Alt + Z` | magnifier: follows the mouse; scroll to zoom, `Esc` to close |
| `Insert` (Orca's key) + `S` | screen reader: speech on / off |

## In a web app

| Keys | What |
| --- | --- |
| `Ctrl + R` | reload |
| `Alt + Left` / `Alt + Right` | back / forward |
| `Ctrl + =` / `Ctrl + -` / `Ctrl + 0` | zoom in / out / reset |
| `Ctrl + L` | copy the page's address |

## In the terminal

| Keys | What |
| --- | --- |
| `Ctrl + R` | search your command history |
| `Ctrl + T` | pick a file, insert its path |
| `Alt + C` | pick a folder, go there |
| `↑` / `↓` | previous commands that start with what you've typed |
| `Esc` | Vim's normal mode on the command line (see [Terminal](07-terminal.md#editing-the-command-line)) |
| `Ctrl + X Ctrl + E` | edit the command in Neovim; save and quit runs it |
| `Alt + .` | insert the last argument of the previous command |
