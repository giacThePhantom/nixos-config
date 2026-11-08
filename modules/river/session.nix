# river session, login, and what the desktop needs from the system.
# The river module also enables polkit, swaylock's PAM entry, dconf,
# XWayland and the wlr + gtk portals.
{ config, ... }:
let
  inherit (config) settings colors;
in
{
  flake.modules.nixos.river =
    {
      pkgs,
      lib,
      ...
    }:
    let
      # Login shell so session variables are loaded; river's output goes to a
      # log for debugging.
      river = toString (
        pkgs.writeShellScript "river-session" ''
          exec ${pkgs.bash}/bin/bash -l -c 'exec river > "$HOME/.local/state/river.log" 2>&1'
        ''
      );

      # ANSI colour names, resolved through the console palette (theme/console.nix):
      # blue = accent, lightcyan = infoLight (the logo's light blue), gray = secondary text
      tuigreetTheme = lib.concatStringsSep ";" [
        "border=blue"
        "title=lightcyan"
        "greet=white"
        "text=gray"
        "time=lightcyan"
        "prompt=lightcyan"
        "input=white"
        "action=darkgray"
        "button=blue"
        "container=black"
      ];
    in
    {
      programs.river-classic = {
        enable = true;
        extraPackages = [ ]; # foot, swaylock etc. come from home-manager
      };

      # Three patches:
      # - `swap` fails when there's no view in that direction (upstream it
      #   silently does nothing), so Super+Shift+HJKL can fall back to sending
      #   the window to the neighbouring monitor.
      # - `riverctl list-views` prints every window with its tags, app-id and
      #   title, which the tag preview (scripts/tag-preview.sh) needs and no
      #   protocol provides.
      # - riverctl printed nothing, or lost the end, of a command's output
      #   (it exited without flushing a 64-byte buffer): list-views needs it.
      nixpkgs.overlays = [
        (final: prev: {
          river-classic = prev.river-classic.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              ./_patches/river-swap-report-no-target.patch
              ./_patches/river-list-views.patch
              ./_patches/riverctl-flush-output.patch
            ];
          });
        })
      ];

      # Boot straight into river (autologin). After logging out of river you land
      # on the tuigreet login screen instead.
      services.greetd = {
        enable = true;
        settings = {
          initial_session = {
            user = settings.user.name;
            command = river;
          };
          default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --greeting 'Welcome back to EnjoyTheLab' --remember --asterisks --theme '${tuigreetTheme}' --cmd ${river}";
        };
      };

      # Faster, leaner D-Bus daemon
      services.dbus.implementation = "broker";

      # Screen sharing (video calls, recording in the browser) goes through
      # the wlr portal; when an app asks, click the monitor to share
      xdg.portal.wlr.settings.screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or -b ${colors.bg}88 -c ${colors.accent}ff";
      };

      # Text-to-speech daemon, enabled by default for graphical desktops (screen
      # readers); ~700 MB of voices and libraries otherwise unused here.
      services.speechd.enable = false;
    };
}
