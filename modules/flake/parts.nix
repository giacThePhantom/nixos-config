# flake-parts plumbing: the systems we build for, the `flake.modules`
# option every feature module adds its NixOS and home-manager parts to,
# `flake.templates` that several modules add project templates to (dev.nix,
# bio/), and `nix fmt`.
{ lib, inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  options.flake = inputs.flake-parts.lib.mkSubmoduleOptions {
    templates = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = { };
      description = "Project templates (`nix flake init -t`, `dvt`), from any module";
    };
  };

  config = {
    systems = [ "x86_64-linux" ];

    perSystem =
      { pkgs, ... }:
      {
        # settings.nix stays hand-formatted so it reads well
        formatter = pkgs.nixfmt-tree.override {
          settings.formatter.nixfmt.excludes = [ "settings.nix" ];
        };
      };
  };
}
