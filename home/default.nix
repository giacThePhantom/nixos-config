# Home-manager entry point. Besides pkgs/lib/config, every module below gets:
#   settings, colors, fonts, inputs  from flake.nix (../settings.nix, ../palette.nix)
#   monitors                         facts derived from settings.monitors (monitors.nix)
{
  pkgs,
  lib,
  inputs,
  settings,
  ...
}:
{
  imports = [
    ./theme
    ./river
    ./dashboard
    ./scripts
    ./desktop.nix
    ./terminal.nix
    ./apps.nix
  ];

  _module.args.monitors = import ./monitors.nix { inherit lib settings; };

  home.username = settings.user.name;
  home.homeDirectory = "/home/${settings.user.name}";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    claude-code
    # Upstream v0.8.1 ships a stale pnpm dependency hash; drop this override
    # once a release fixes it.
    (inputs.rencal.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      pnpmDeps = old.pnpmDeps.overrideAttrs {
        outputHash = "sha256-7A4skNohokIWHI4AjTZJCwWHzL8AYvf3GeqfkQjwwpU=";
      };
    }))
    # Spotify comes from programs.spicetify (theme/apps.nix)
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Electron/Chromium apps run natively on Wayland
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = settings.user.gitName;
      inherit (settings.user) email;
    };
  };
}
