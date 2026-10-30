# Machines: each `configurations.nixos.NAME.module` (see ../hosts) becomes
# `nixosConfigurations.NAME`, the target of `nixos-rebuild --flake .#NAME`,
# and a flake check, so `nix flake check` builds every machine.
{
  lib,
  config,
  inputs,
  ...
}:
{
  options.configurations.nixos = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.module = lib.mkOption { type = lib.types.deferredModule; };
      }
    );
    default = { };
  };

  config.flake = {
    nixosConfigurations = lib.mapAttrs (
      _: { module }: inputs.nixpkgs.lib.nixosSystem { modules = [ module ]; }
    ) config.configurations.nixos;

    checks = lib.foldl lib.recursiveUpdate { } (
      lib.mapAttrsToList (name: nixos: {
        ${nixos.config.nixpkgs.hostPlatform.system}."nixos-${name}" = nixos.config.system.build.toplevel;
      }) config.flake.nixosConfigurations
    );
  };
}
