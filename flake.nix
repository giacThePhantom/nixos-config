{
  description = "Minimal river desktop on NixOS + home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Dendritic layout: every .nix file under ./modules is a flake-parts
    # module, imported automatically (files and dirs starting with `_` are not)
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Not in nixpkgs; upstream flake pinned to a release tag, built with our
    # nixpkgs (modules/apps.nix pins the JS dependency hash for our pnpm).
    rencal = {
      url = "github:t4t5/rencal/v0.8.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Spotify with a palette colour scheme (modules/theme/apps.nix)
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Per-project dev environments (modules/dev.nix); only its templates are
    # used, so its own nixpkgs is never fetched
    dev-templates = {
      url = "github:the-nix-way/dev-templates";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Index of nixpkgs for comma (`, tool`) and "command not found"
    # suggestions (modules/dev.nix), prebuilt upstream
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Terminal workspace for AI coding agents (modules/dev.nix); not in
    # nixpkgs, built from source with our nixpkgs
    herdr = {
      url = "github:ogulcancelik/herdr/v0.9.5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
