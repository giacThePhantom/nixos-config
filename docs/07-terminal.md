# Terminal

`Super + Return` opens a terminal (foot: fast, light). You'll spend a lot of
time here, so it comes with modern versions of the classic tools.

## The shell

The prompt shows the folder you're in, the git branch and its state, and
how long the last command took if it was slow. A few things work
differently from a stock terminal:

| Type | What it does |
| --- | --- |
| `ls`, `ll`, `la`, `tree` | list files, with icons and git status (eza) |
| `cat file` | show a file with colours and line numbers (bat) |
| `z name` | jump to a folder you've visited before, by part of its name (zoxide) |
| `y` | browse files (yazi); quitting leaves you in the folder you were in |
| `Ctrl + R` | search your command history |
| `Ctrl + T` / `Alt + C` | pick a file / go to a folder, by fuzzy search |
| `rg text` | search inside files, fast (ripgrep) |
| `fd name` | find files by name |
| `tldr tar` | examples of how to use a command, instead of its long manual |
| `, tool` | run any tool once without installing it (see [Projects](10-projects.md)) |
| `rebuild` | apply changes to the system |

Typing a command that isn't installed tells you which package has it.

## Editing the command line

The command line uses Vim's keys, like Neovim. You type as usual (a bar
cursor); `Esc` switches to *normal mode* (a block cursor), where keys move
and edit instead of typing; `i` or `a` goes back to typing.

| In normal mode | What |
| --- | --- |
| `h` / `l`, `w` / `b`, `0` / `$` | move: a character, a word, start / end of line |
| `x`, `dw`, `cw`, `D`, `C` | delete a character, a word; change a word; delete / change to the end |
| `u` | undo |
| `k` / `j` (or `↑` / `↓`) | older / newer commands starting with what's typed |
| `/text` | search the history for `text` (`n` for the next match) |
| `v` | edit the command in Neovim; save and quit runs it |
| `_` | insert the last argument of the previous command |

While typing, a few keys from other terminals still work: `↑` / `↓` (history
by prefix), `Ctrl + A` / `Ctrl + E` (start / end of line), `Ctrl + W`
(delete a word), `Ctrl + U` (delete the line), `Alt + .` (last argument),
`Ctrl + L` (clear the screen), and fzf's `Ctrl + R`, `Ctrl + T`, `Alt + C`.

`Tab` completes; when there are several matches it lists them all at once.
Case doesn't matter, and `-` matches `_`.

These settings live in `~/.config/inputrc` (generated from
`modules/terminal.nix`). Vim keys apply to bash only; other programs that
use the same line editor (R, sqlite) keep the standard keys. `cheat bash`
has the rest of what bash can do: history tricks, `**` globs, loops over
samples, job control.

## zellij and herdr: panes, tabs, sessions

A plain terminal (`Super + Return`) is one shell. When you want several
things side by side, or something that keeps running after you close the
window, open one of these instead:

| | zellij (`Super + Alt + Return`) | herdr (`Super + Ctrl + Return`) |
| --- | --- | --- |
| For | everyday work: an editor, a shell, a log, side by side | AI coding agents (Claude Code...), several at once |
| Organised as | sessions → tabs → panes | workspaces (one per project) → tabs → panes |
| Extra | floating panes, scrollback in Neovim | a sidebar showing which agent is working and which is waiting for you |

Both survive closing the window: detach, and everything inside keeps
running; open it again to pick up where you were.

They share one rule, so you only learn it once: **every key goes to the
program inside**, until you press the leader, **`Ctrl + Space`**. The next
key then acts on zellij or herdr, and the one after goes back to the
program. `v` splits in both, `h j k l` moves in both, `c` makes a tab in
both. In zellij, `Ctrl + Space` again (or `Esc`) cancels.

### zellij

| `Ctrl + Space`, then | |
| --- | --- |
| `v` / `-` | split: new pane to the right / below |
| `h` `j` `k` `l` (or arrows) | move to the pane on that side |
| `H` `J` `K` `L` | move the pane itself, swapping it with its neighbour |
| `x` / `X` | close the pane / the whole tab |
| `P` | name the pane: type, `Enter` (or `Esc` to cancel) |
| `s` | type in every pane of the tab at once (the same command on several servers); again to stop |
| `z` | zoom: the pane fills the tab; again to go back |
| `f` | floating panes: show / hide them (the first time, opens one; splitting while they show adds floating ones) |
| `c` | new tab |
| `n` / `p` / `1`…`9` | next / previous / that tab |
| `<` / `>` | move the tab left / right |
| `T` | rename the tab: type, `Enter` (or `Esc` to cancel) |
| `r` | resize mode (below) |
| `[` | scroll mode (below) |
| `w` | sessions: switch to another, or reopen one that was closed |
| `d` or `q` | detach: leave, everything keeps running |

**Resize mode** (`r`): `h j k l` grow the pane on that side, `H J K L`
shrink it; `Esc` or `Enter` when done.

**Scroll mode** (`[`): `j` / `k` a line, `Ctrl + D` / `Ctrl + U` (or Page
Down / Page Up) half a page, `/` to search (type, `Enter`, then `n` / `N`
for the next / previous match), `e` to open the whole scrollback in Neovim
(to search, copy or save it); `Esc` or `q` to get back.

Without the leader, `Ctrl + H / J / K / L` moves to the pane on that side,
and inside Neovim it moves between Neovim's splits first, then out into the
next pane. (In the shell this takes `Ctrl + L`: type `clear` instead.)
Neovim's half is [zellij-nav.nvim](https://github.com/swaits/zellij-nav.nvim),
in your Neovim configuration (`~/.config/nvim/lua/plugins/zellij-nav.lua`).

The bar at the bottom shows the session's name and its tabs; on the right,
the mode while a leader command is under way (`LEADER`, `RESIZE`,
`SCROLL`...), with its keys.

The first time zellij starts, its two plugins (the bar and the `Ctrl + H/J/K/L`
helper) each ask for permission in a small window: press `y` in each. They
remember it, also across updates.

Ready-made layouts, from a project folder:

```sh
zellij -l analysis   # Neovim, a shell beside it, the job queue (pueue) below
zellij -l cluster    # `ssh hpc` and, after Enter, your jobs in its queue
```

`cluster` uses the host you named `hpc` in `~/.ssh/config.d/` (see
[Research tools](09-research.md)); the queue pane waits for `Enter` so it
reuses your login instead of asking for the password again.

Sessions from the shell:

```sh
zellij -s analysis        # a new session called "analysis"
zellij ls                 # sessions, running and closed
zellij attach analysis    # back into it (zellij a analysis)
zellij kill-session NAME  # stop one; delete-session also forgets it
```

Sessions survive a restart. zellij saves each one every 30 seconds: its
tabs, panes and their sizes, each pane's folder and command, and what the
panes showed (with the last 2000 lines of scrollback). After a restart they
are listed as *EXITED*; `zellij attach analysis`, or `Ctrl + Space` `w` and
picking it, brings it back as you left it. Panes that were running a
program (Neovim, `ssh`, a pipeline) show it waiting: press `Enter` to start
it again. Programs don't resume where they were, only the layout around
them does, so save your work as usual.

How it's set up (`programs.zellij` in `modules/terminal.nix`, which writes
`~/.config/zellij/config.kdl`):
- it starts *locked*, the mode where it ignores keys, and goes back to it
  after every leader command: that is what makes `Ctrl + Space` a leader,
  like tmux's prefix, instead of zellij's default of many `Ctrl` shortcuts
  that clash with programs inside;
- a bar with the session and its tabs (zjstatus), no frames around panes, no tips at start;
- colours from the palette, like the terminal;
- it only starts when asked: plain terminals stay plain.

### herdr

`herdr` (or `Super + Ctrl + Return`) opens your herdr session, or goes back
into it: it keeps running in the background (`herdr --session NAME` keeps
separate ones, if you ever want them). The sidebar
on the left lists workspaces and the agents in them, with their state.

| `Ctrl + Space`, then | |
| --- | --- |
| `v` / `-` | split: new pane to the right / below |
| `h` `j` `k` `l` | move to the pane on that side |
| `Tab` / `Shift + Tab` | next / previous pane |
| `x` | close the pane |
| `z` | zoom the pane; again to go back |
| `r` | resize mode |
| `e` | open the pane's scrollback in Neovim |
| `c` / `n` / `p` / `1`…`9` | new tab / next / previous / that tab |
| `g` | jump to any agent |
| `w` | pick a workspace |
| `o` | jump to what the last notification was about (an agent waiting) |
| `b` | show / hide the sidebar |
| `Shift + N` / `Shift + G` | new workspace / new git worktree (an agent on its own branch) |
| `Shift + T` / `Shift + P` / `Shift + W` | rename the tab / pane / workspace |
| `Shift + X` / `Shift + D` | close the tab / workspace |
| `Shift + R` | reload the settings (after `rebuild`) |
| `?` | every key |
| `q` | detach: leave, the agents keep working |

`herdr server stop` ends the session and everything in it.

How it's set up (`modules/terminal.nix`, which writes
`~/.config/herdr/config.toml`): the leader is `Ctrl + Space` instead of
herdr's `Ctrl + B`, colours follow the terminal's (so the palette), and the
first-run tour is off. The file is read-only, so herdr's own settings
screen (`Ctrl + Space`, `s`) can't save: change settings in
`modules/terminal.nix`, `rebuild`, then `Ctrl + Space`, `Shift + R`.

## Other tools

- `btop` (or *Open monitor* in the System panel, `Super + I`): what's using your processor, memory, disks, network.
- `nvtop`: the same, for the graphics card.
- `gh`: GitHub from the terminal (`gh auth login` once, then `gh repo clone`,
  `gh pr create`...).
- `cheat samtools` (or `cheat` to pick one): the commands you keep looking
  up, for bio tools, SLURM, Snakemake, git and more; `q` to close.
- `alert`: a notification when a command ends (done or failed, and how long
  it took), so you can look away: `alert bwa index ref.fa`.
- `jq`: read and filter JSON.
- `fastfetch`: a summary of your system, for screenshots.
- `nvim` is the text editor (`vi` and `vim` open it too): see
  [The editor](15-editor.md).

Next: [Applications](08-applications.md).
