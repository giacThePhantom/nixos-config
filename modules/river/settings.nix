# river window manager: look and input here; keybindings, window rules and
# the session's programs in the other files here, which add to the same
# module. Everything ends up in ~/.config/river/init, a script river runs at
# startup.
{ config, ... }:
let
  inherit (config) colors monitors settings;
  kb = settings.keyboard;
in
{
  flake.modules.homeManager.river =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {

      home.packages = with pkgs; [
        rivercarro # layout generator: master/stack + monocle, per tag
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
          # settings.nix: keyboard
          keyboard-layout = lib.concatStringsSep " " (
            lib.optional (kb.variant != "") "-variant ${kb.variant}"
            ++ lib.optional (kb.options != "") "-options ${kb.options}"
            ++ [ kb.layout ]
          );
          # The cursor theme/gtk.nix sets (accessibility makes it bigger)
          xcursor-theme = "${config.home.pointerCursor.name} ${toString config.home.pointerCursor.size}";
          # New windows never land on the scratchpad tag
          spawn-tagmask = toString monitors.visibleTags;
        };
      };
    };
}
