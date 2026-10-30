# Laptops: power modes (Super+D > System), battery in the system panel,
# brightness keys, touchpad tap-to-click and natural scrolling. Add `laptop`
# to both lists of a host that is a laptop. Lid closed = suspend, locked
# first (river/autostart.nix), which is logind's default.
{ config, ... }:
let
  inherit (config) settings;
in
{
  flake.modules.nixos.laptop =
    { pkgs, ... }:
    {
      services.power-profiles-daemon.enable = true; # performance / balanced / power-saver
      services.upower.enable = true; # battery state for apps that ask
      # brightnessctl's udev rules let the video group set the backlight
      services.udev.packages = [ pkgs.brightnessctl ];
      users.users.${settings.user.name}.extraGroups = [ "video" ];
    };

  flake.modules.homeManager.laptop =
    { lib, pkgs, ... }:
    let
      brightness = step: "spawn '${pkgs.brightnessctl}/bin/brightnessctl set ${step}'";
      brightnessKeys = {
        "None XF86MonBrightnessUp" = brightness "5%+";
        "None XF86MonBrightnessDown" = brightness "5%-";
      };
    in
    {
      # Held down they repeat, and they work on the lock screen too
      wayland.windowManager.river.settings.map."-repeat" = {
        normal = brightnessKeys;
        locked = brightnessKeys;
      };

      # Before autostart.nix, whose reload pass stops early. Quoted: the
      # patterns are river's, not the shell's.
      wayland.windowManager.river.extraConfig = lib.mkBefore ''
        for pad in '*Touchpad*' '*touchpad*' '*TouchPad*'; do
          riverctl input "$pad" tap enabled
          riverctl input "$pad" natural-scroll enabled
          riverctl input "$pad" disable-while-typing enabled
        done
      '';
    };
}
