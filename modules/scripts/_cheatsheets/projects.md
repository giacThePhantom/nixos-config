# Project environments (Nix)

    dvt bio python qc snakemake        # new project: environment + standard layout
    dvt                                # pick a template (python, r, rust, latex, typst...)
    direnv allow                       # after creating or changing .envrc
    nix flake update                   # newer versions of everything (then test!)
    nix develop                        # the environment without direnv
    nix build .#container              # the environment as a container image
    , tool args                        # any tool once, without installing it
    nix search nixpkgs salmon          # find a package name (or search.nixos.org)
    nix flake metadata                 # the exact nixpkgs revision (for methods)

Add packages: edit `flake.nix` (`use = { ... }`, or `extra`, `extraPython`, `extraR`),
save, run any command.
Commit `flake.nix` and `flake.lock`: together they are the exact environment.
