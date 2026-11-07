# Opt-in: accessibility. The Orca screen reader, started at login (quit:
# Orca+Q, the Orca key is Insert; again: Super+Space > Setup > Screen reader),
# with speech; a magnifier on Super+Alt+Z (it follows the mouse, Esc
# closes); larger text in apps and a larger cursor. +760 MiB, almost all of
# it the voices. Enable it in both lists in hosts/.
{
  flake.modules.nixos.accessibility =
    { lib, pkgs, ... }:
    {
      services.speechd.enable = lib.mkForce true; # river/session.nix turns it off
      services.gnome.at-spi2-core.enable = true; # the bus apps describe themselves on
      environment.systemPackages = [ pkgs.orca ];
    };

  flake.modules.homeManager.accessibility =
    { lib, pkgs, ... }:
    {
      home.packages = [ pkgs.wooz ];

      gtk.font.size = lib.mkForce 13; # from 11
      dconf.settings."org/gnome/desktop/interface".text-scaling-factor = 1.25; # GTK 4 apps
      home.pointerCursor.size = lib.mkForce 36; # from 24

      wayland.windowManager.river.settings.map.normal."Super+Alt Z" =
        "spawn '${pkgs.wooz}/bin/wooz --mouse-track'";
      # After the session-start guard in river/autostart.nix
      wayland.windowManager.river.extraConfig = lib.mkAfter ''
        orca --replace &
      '';
    };
}
