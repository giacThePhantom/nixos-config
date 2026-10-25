# Window rules. Re-applied by river-reload (Super+Shift+R).
{
  lib,
  monitors,
  ...
}:
let
  # Windows that start floating, as riverctl rule matchers
  floating = [
    "-app-id com.saivert.pwvucontrol"
    "-title Picture-in-Picture"
    "-app-id xdg-desktop-portal-gtk" # file pickers
    "-app-id polkit-gnome-authentication-agent-1"
    "-app-id 'pinentry-*'"
    "-app-id nm-connection-editor"
    "-app-id blueman-manager"
    "-app-id zenity"
    "-app-id firefox -title 'File Upload'"
    "-app-id firefox -title Library"
    "-app-id firefox -title 'About Mozilla Firefox'"
    "-app-id steam -title 'Friends List'"
    "-app-id steam -title 'Steam Settings'"
  ];

  # Scratchpad terminal: 1400x800, centred on the primary monitor
  scratch = {
    w = 1400;
    h = 800;
    x = (monitors.primary.width - 1400) / 2;
    y = (monitors.primary.height - 800) / 2;
  };
in
{
  # Before autostart.nix, whose reload pass stops early
  wayland.windowManager.river.extraConfig = lib.mkBefore ''
    # Server-side decorations everywhere: borders instead of fat client titlebars
    riverctl rule-add -app-id '*' ssd
    ${lib.concatMapStringsSep "\n" (m: "riverctl rule-add ${m} float") floating}

    # Scratchpad terminal (Super+`), on its hidden tag
    riverctl rule-add -app-id scratchpad float
    riverctl rule-add -app-id scratchpad tags ${toString monitors.scratchTag}
    riverctl rule-add -app-id scratchpad dimensions ${toString scratch.w} ${toString scratch.h}
    riverctl rule-add -app-id scratchpad position ${toString scratch.x} ${toString scratch.y}
  '';
}
