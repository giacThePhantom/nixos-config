{ pkgs, inputs, ... }:

{
  imports = [
    ./modules/theme.nix
    ./modules/river.nix
    ./modules/dashboard.nix
    ./modules/desktop.nix
    ./modules/terminal.nix
    ./modules/apps.nix
  ];

  home.username = "giacthephantom";
  home.homeDirectory = "/home/giacthephantom";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    spotify
    claude-code
    # Upstream v0.8.1 ships a stale pnpm dependency hash; drop this override
    # once a release fixes it.
    (inputs.rencal.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      pnpmDeps = old.pnpmDeps.overrideAttrs {
        outputHash = "sha256-7A4skNohokIWHI4AjTZJCwWHzL8AYvf3GeqfkQjwwpU=";
      };
    }))
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Electron/Chromium apps run natively on Wayland
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "giacThePhantom";
      email = "giacomo.fantoni@unitn.it";
    };
  };
}
