# The one file to edit to make this configuration yours. Read by both the
# system (flake.nix) and home-manager modules as the `settings` argument.
{
  user = {
    name = "giacthephantom"; # login name
    fullName = "Giacomo Fantoni";
    gitName = "giacThePhantom";
    email = "giacomo.fantoni@unitn.it";
  };

  hostname = "nixos"; # also the flake output name: `nixos-rebuild --flake .#nixos`

  # Your university's GlobalProtect VPN portal, for `vpn` (Super+Shift+V)
  vpnPortal = "vpn-mfa.icts.unitn.it";

  # Keyboard layout, for the desktop and the text consoles. Two layouts:
  # layout = "us,it"; options = "grp:alt_shift_toggle"; (Alt+Shift switches).
  # Names: `localectl list-x11-keymap-layouts`, `…-variants it`, `…-options`.
  keyboard = {
    layout = "us";
    variant = ""; # e.g. "intl", "dvorak", "colemak"
    options = ""; # e.g. "caps:escape" (Caps Lock as a second Escape)
  };

  # Monitors from left to right, by connector name (`wlr-randr` lists them).
  # Each owns a set of tags: Super+N jumps to the monitor that owns tag N
  # (tag 10 is on key 0). The primary monitor gets focus at login and shows
  # the dashboard.
  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      tags = [ 1 2 3 4 5 ];
    }
  ];
}
