# Window rules. Re-applied by river-reload (Super+Shift+R).
{ config, ... }:
let
  inherit (config) monitors;
in
{
  flake.modules.homeManager.river =
    {
      lib,
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
        "-app-id gcr-prompter" # password dialogs (rbw)
        "-app-id cheatsheet" # cheat sheets from the launcher
        "-app-id nm-connection-editor"
        "-app-id blueman-manager"
        "-app-id zenity"
        "-app-id firefox -title 'File Upload'"
        "-app-id firefox -title Library"
        "-app-id firefox -title 'About Mozilla Firefox'"
        "-app-id steam -title 'Friends List'"
        "-app-id steam -title 'Steam Settings'"
      ];
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
        # Its size and position, and the cheat sheets' size, depend on the first
        # monitor and its scale: `monitors apply` sets them (scripts/monitors.sh)

        # Mirror layout: wl-mirror windows on the hidden mirror tag (monitors.sh
        # puts each on its monitor, by title)
        riverctl rule-add -app-id at.yrlf.wl_mirror tags ${toString monitors.mirrorTag}
        riverctl rule-add -app-id at.yrlf.wl_mirror fullscreen
      '';
    };
}
