{ pkgs, ... }:

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
