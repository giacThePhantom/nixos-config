# home-manager inside the system build (one `rebuild` applies both), and the
# user basics: identity, git, session variables. Which home modules the user
# gets is listed per machine in hosts/.
{ config, inputs, ... }:
let
  inherit (config) settings;
in
{
  flake.modules.nixos.home = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    # One nixpkgs for system and home, no second evaluation
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup";
  };

  flake.modules.homeManager.base = {
    home.username = settings.user.name;
    home.homeDirectory = "/home/${settings.user.name}";
    home.stateVersion = "26.05";

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
  };
}
