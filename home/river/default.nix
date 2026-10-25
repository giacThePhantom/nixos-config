# river window manager: look and input here; keybindings, window rules and
# the session's programs in the files imported below. Everything ends up in
# ~/.config/river/init, a script river runs at startup.
{
  pkgs,
  colors,
  monitors,
  ...
}:
{
  imports = [
    ./keys.nix
    ./rules.nix
    ./autostart.nix
  ];

  home.packages = with pkgs; [
    rivercarro # layout generator: master/stack + monocle, per tag
    river-tag-overlay # tag popup when switching (there is no bar)
  ];

  wayland.windowManager.river = {
    enable = true;
    package = null; # installed system-wide by programs.river-classic
    xwayland.enable = false; # likewise
    # No systemd user session: river's init starts everything itself
    systemd.enable = false;

    extraSessionVariables = {
      XDG_CURRENT_DESKTOP = "river";
      XDG_SESSION_DESKTOP = "river";
    };

    settings = {
      background-color = "0x${colors.bgInput}";
      border-width = 2;
      border-color-focused = "0x${colors.accent}";
      border-color-unfocused = "0x${colors.bgTertiary}";
      border-color-urgent = "0x${colors.danger}";

      default-layout = "rivercarro";
      focus-follows-cursor = "normal";
      set-cursor-warp = "on-focus-change";
      hide-cursor.when-typing = "enabled";
      set-repeat = "50 300";
      xcursor-theme = "Bibata-Modern-Classic 24";
      # New windows never land on the scratchpad tag
      spawn-tagmask = toString monitors.visibleTags;
    };
  };
}
