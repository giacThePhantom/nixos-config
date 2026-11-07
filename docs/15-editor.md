# The editor: Neovim

`nvim` (or `vi`, `vim`) is the text editor, in the terminal. It is set up
for code: finding files, searching a whole project, completion, errors as
you type, fixes and refactoring through the language's own tools.

## Where its settings live

Not in this configuration: `~/.config/nvim` is its own git repository, in
Lua. Edit a file there, restart Neovim, and the change is live; commit and
push it like any project. The same repository works on any machine with
Neovim 0.12, the cluster included (see [Another machine](#another-machine)).

The system gives Neovim what it needs around it: the desktop's colours, the
tools its plugins call, and the language servers for Nix and shell scripts.
`~/.config/nixos` never writes into `~/.config/nvim`; the build stops if it
tries.

The first time you open it, Neovim downloads its plugins and builds the
syntax grammars: a minute, once. Plugin versions are pinned in
`nvim-pack-lock.json`, so every machine gets the same ones.

## Keys

`Space` is the *leader*: press it and wait, and a panel shows what can
follow. The same for `g`, `]` and `[`.

| Keys | What |
| --- | --- |
| `Space Space` | find a file in the project |
| `Space /` | search the whole project (as you type) |
| `Space f r` / `Space f b` | recent files / open files |
| `Space s w` | search the word under the cursor, everywhere |
| `Space s d` | every error and warning in the project |
| `Space s h` / `Space s k` | search the help / the keys |
| `Space s r` | back to the last search, where you left it |
| `Ctrl + S` | save |
| `Shift + H` / `Shift + L` | previous / next open file |
| `Ctrl + H/J/K/L` | move between split windows; at the edge, on to the next zellij pane |
| `Space q q` | quit |

In a picker: type to filter, `Ctrl + N` / `Ctrl + P` (or the arrows) to
move, `Enter` to open, `Ctrl + V` to open beside, `Esc` to close.

### Code

| Keys | What |
| --- | --- |
| `Space c a` | code actions: fixes, imports, refactorings for what's under the cursor |
| `Space c r` | rename everywhere |
| `Space c f` | format (also done on save) |
| `Space c d` | the error on this line, in full |
| `]d` / `[d` | next / previous error or warning |
| `gd` | go to the definition (`Ctrl + O` to come back) |
| `gr` | everywhere this is used |
| `gI` / `gy` | implementations / type definition |
| `K` | documentation for what's under the cursor |
| `Space s s` / `Space s S` | functions and classes in this file / the project |

While typing, suggestions appear by themselves: `Ctrl + N` / `Ctrl + P` to
move, `Ctrl + Y` to accept, `Ctrl + E` to close.

### Git

| Keys | What |
| --- | --- |
| `]h` / `[h` | next / previous change |
| `Space g p` | what changed here |
| `Space g s` / `Space g r` | stage / undo this change |
| `Space g b` | who wrote this line, and in which commit |
| `Space g S` / `Space g c` | changed files / commits |

### Toggles

`Space u f` format on save, `Space u w` line wrap, `Space u d` errors and
warnings, `Space u h` type hints, `Space u m` Markdown rendering.

Markdown files show rendered: headings, lists, tables, code blocks and
checkboxes are drawn in place, and the line you're on (or all of it, in
insert mode) shows the plain text you type.

## Languages in projects

Completion, errors and code actions come from a *language server*, one per
language. Only Nix and shell scripts have one everywhere; the others come
with each project's environment, so their versions match the project's:
the `bio` template includes them for Python (basedpyright, ruff) and R
(`languageserver`), as `languageServers = true` in its `flake.nix`.

So start Neovim inside the project (`cd project && nvim`): direnv has loaded
its environment, and Neovim finds the servers there. For other templates,
add the server to the project's `flake.nix`, e.g. `pkgs.texlab` (LaTeX),
`pkgs.tinymist` (Typst), `pkgs.rust-analyzer`. The servers Neovim knows are
listed in `lua/plugins/lsp.lua` in its repository.

Formatting on save uses the project's formatter when it has one (ruff,
nixfmt, shfmt...). `settings.nix` in `~/.config/nixos` is never reformatted.

## Updating plugins

Inside Neovim, `:lua vim.pack.update()` shows what would change; `:write`
confirms. Then commit `nvim-pack-lock.json`. If an update breaks something,
`git checkout HEAD -- nvim-pack-lock.json` and restart.

## Another machine

```sh
git clone YOUR-REPOSITORY ~/.config/nvim
nvim   # installs the plugins at the versions in the lock file
```

Off NixOS it needs Neovim 0.12 or newer, `git`, `ripgrep` and `fd`, and,
for syntax grammars, a C compiler and the `tree-sitter` command. On a
cluster without them, Neovim still works, with simpler highlighting.

Next: back to [the manual](README.md).
