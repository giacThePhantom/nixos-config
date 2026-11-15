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

  # Monitors are found as they are plugged in, and laid out left to right:
  # the laptop's own screen first, then the others (swap them from
  # Super+D). Each owns some tags: Super+N jumps to the monitor that owns
  # tag N (tag 10 is on key 0). Tags no monitor owns go to the first one,
  # which also shows the dashboard. Super+D switches the layout (automatic,
  # presentation, mirror) and each monitor's scale.
  monitors = {
    # Automatic layout, by number of monitors; with any other number the
    # tags are shared out evenly
    layouts = {
      "1" = [ [ 1 2 3 4 5 6 7 8 9 10 ] ];
      "2" = [ [ 1 2 3 4 5 ] [ 6 7 8 9 10 ] ];
      "3" = [ [ 1 ] [ 2 3 4 5 ] [ 6 7 8 9 10 ] ];
    };

    # Presentation: the laptop and the projector (tags 9-10 stay on the laptop)
    presentation = [ [ 1 2 ] [ 3 4 5 6 7 8 ] ];

    # Fixed scales (1 = 100%, 1.5 = 150%...), by connector or by
    # "make model serial" (both from `wlr-randr`). The others are chosen from
    # the pixel density, or picked in Super+D, which wins over these.
    scale = {
      # "eDP-1" = 1.25;
    };
  };
}
