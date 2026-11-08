# Notifications and lock screen config (the launcher is in launcher/). The
# daemons themselves are started from the river init (see river/autostart.nix).
{ config, ... }:
let
  inherit (config) colors fonts;
in
{
  flake.modules.homeManager.desktop =
    {
      pkgs,
      ...
    }:
    let
      c = colors;
    in
    {
      services.mako = {
        enable = true;
        settings = {
          font = "${fonts.ui} 11";
          background-color = "#${c.bg}";
          text-color = "#${c.text}";
          border-color = "#${c.accent}";
          progress-color = "over #${c.bgTertiary}";
          border-size = 2;
          border-radius = 10;
          padding = "12";
          margin = "10";
          width = 360;
          default-timeout = 5000;
          icons = true;
          max-icon-size = 48;
          "urgency=high" = {
            border-color = "#${c.warning}";
            default-timeout = 0;
          };
          # Do not disturb (Super+Ctrl+N, scripts/dnd.sh), e.g. while sharing
          # the screen: nothing shows, and what arrives waits until it's off
          "mode=do-not-disturb" = {
            invisible = 1;
            ignore-timeout = 1;
            default-timeout = 0;
          };
        };
      };

      # Screenshot annotation (Ctrl+Print, scripts/screenshot.sh): arrows first,
      # the pens in the palette's colours
      xdg.configFile."satty/config.toml".text = ''
        [general]
        initial-tool = "arrow"
        early-exit = true
        copy-command = "wl-copy"
        no-window-decoration = true # river draws the border, like every window

        [font]
        family = "${fonts.ui}"

        [color-palette]
        palette = ["#${c.accent}", "#${c.danger}", "#${c.warning}", "#${c.success}", "#${c.info}", "#${c.text}"]
      '';

      programs.swaylock = {
        enable = true;
        settings = {
          # The logo centred, the name below: the ring appears around the logo
          # while typing (radius and image are sized together in _wallpaper.nix)
          image = "${(import ./theme/_wallpaper.nix { inherit pkgs colors fonts; }).lock}";
          scaling = "fill";
          font = fonts.mono;
          indicator-radius = 110;
          indicator-thickness = 8;
          show-failed-attempts = true;
          color = c.bg;
          inside-color = "00000000"; # the logo shows through while typing
          # Verifying, wrong, cleared: a message over the logo, on a backdrop
          inside-clear-color = "${c.bg}cc";
          inside-ver-color = "${c.bg}cc";
          inside-wrong-color = "${c.bg}cc";
          ring-color = c.bgSecondary;
          ring-clear-color = c.warningText;
          ring-ver-color = c.infoText;
          ring-wrong-color = c.danger;
          key-hl-color = c.accent;
          bs-hl-color = c.dangerText;
          line-color = "00000000";
          line-clear-color = "00000000";
          line-ver-color = "00000000";
          line-wrong-color = "00000000";
          separator-color = "00000000";
          text-color = c.text;
          text-clear-color = c.text;
          text-ver-color = c.text;
          text-wrong-color = c.danger;
        };
      };

      home.packages = with pkgs; [
        wl-clipboard
        grim
        slurp
        wireplumber
        wlr-randr # monitor layout: `wlr-randr --output DP-1 --mode 2560x1440@144`
        libnotify
        playerctl
        pwvucontrol
        xdg-utils
      ];
    };
}
