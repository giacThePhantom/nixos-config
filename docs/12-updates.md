# Updates

## Updating everything

```sh
cd ~/.config/nixos
nix flake update     # fetch the newest versions of everything
rebuild              # switch to them
```

Every app, tool and the kernel move together, tested together. Do it every
week or two, when you have a few minutes; not right before a deadline.

Your projects don't change when the system updates: they keep the versions
in their own `flake.lock` until you run `nix flake update` inside them.

## Going back

Every `rebuild` creates a new version of the system (the *generation*; the
System panel, `Super + I`, shows its number). The old ones stay:

- If an update breaks something, restart and pick the previous generation in
  the boot menu.
- To make the rollback permanent, undo the change in `~/.config/nixos`
  (`git checkout flake.lock`, or your edit) and `rebuild`.

Use git to keep your changes safe: `git commit -am "what I changed"` after
something works.

## Disk space

Old generations and unused downloads are cleaned up every week, keeping
two weeks of history. To free space now:

```sh
sudo nix-collect-garbage --delete-older-than 7d
```

Project environments you still use are kept; deleted projects' environments
go away at the next cleanup.

Next: [Troubleshooting](13-troubleshooting.md).
