# Passwords from Bitwarden (or Vaultwarden): Super+Shift+P, or Super+Space >
# Passwords, finds an entry and copies its password, cleared from the
# clipboard after 30 s. rbw is the client; `rbw unlock` asks for the master
# password in a small dialog, `rbw sync` refreshes, `rbw get NAME` in scripts.
{ config, ... }:
let
  inherit (config) settings;
in
{
  # The dialog rbw asks the master password in (pinentry-gnome3) is drawn by
  # gcr's prompter, which needs its D-Bus service registered outside GNOME
  flake.modules.nixos.passwords =
    { pkgs, ... }:
    {
      services.dbus.packages = [ pkgs.gcr_3 ]; # the version pinentry-gnome3 uses
    };

  flake.modules.homeManager.passwords =
    { pkgs, ... }:
    {
      programs.rbw = {
        enable = true;
        settings = {
          # Your Bitwarden account; change it if it isn't your settings.nix email
          email = settings.user.email;
          # base_url = "https://vault.example.org"; # a self-hosted Vaultwarden
          lock_timeout = 3600; # ask for the master password again after an hour
          pinentry = pkgs.pinentry-gnome3;
        };
      };

      home.packages = [ pkgs.rofi-rbw-wayland ];
      # The picker: the launcher's rofi theme; Enter copies the password
      xdg.configFile."rofi-rbw.rc".text = ''
        action = copy
        clipboarder = wl-copy
        typer = wtype
        clear-after = 30
        selector = rofi
        prompt = Passwords
      '';

      wayland.windowManager.river.settings.map.normal."Super+Shift P" = "spawn rofi-rbw";
    };
}
