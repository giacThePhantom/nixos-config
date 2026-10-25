# river session, login, and what the desktop needs from the system.
# The river module also enables polkit, swaylock's PAM entry, dconf,
# XWayland and the wlr + gtk portals.
{ pkgs, ... }:
let
  # Login shell so session variables are loaded; river's output goes to a
  # log for debugging.
  river = toString (
    pkgs.writeShellScript "river-session" ''
      exec ${pkgs.bash}/bin/bash -l -c 'exec river > "$HOME/.local/state/river.log" 2>&1'
    ''
  );
in
{
  programs.river-classic = {
    enable = true;
    extraPackages = [ ]; # foot, swaylock etc. come from home-manager
  };

  # `swap` fails when there's no view in that direction (upstream it silently
  # does nothing), so Super+Shift+HJKL can fall back to sending the window to
  # the neighbouring monitor.
  nixpkgs.overlays = [
    (final: prev: {
      river-classic = prev.river-classic.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./patches/river-swap-report-no-target.patch ];
      });
    })
  ];

  # Boot straight into river (autologin). After logging out of river you land
  # on the tuigreet login screen instead.
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        user = "giacthephantom";
        command = river;
      };
      default_session.command =
        "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd ${river}";
    };
  };

  # Faster, leaner D-Bus daemon
  services.dbus.implementation = "broker";
}
