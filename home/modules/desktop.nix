# Launcher, notifications and lock screen config. The daemons themselves are
# started from the river init (see river.nix).
{ pkgs, ... }:
let
  c = import ./palette.nix;
in
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "${c.uiFont}:size=12";
        terminal = "footclient";
        icon-theme = "Papirus-Dark";
        prompt = "'󰍉  '";
        width = 40;
        lines = 10;
        horizontal-pad = 20;
        vertical-pad = 12;
        inner-pad = 8;
        layer = "overlay";
      };
      colors = {
        background = "${c.base}f2";
        text = "${c.text}ff";
        prompt = "${c.subtext1}ff";
        placeholder = "${c.overlay1}ff";
        input = "${c.text}ff";
        match = "${c.mauve}ff";
        selection = "${c.surface1}ff";
        selection-text = "${c.text}ff";
        selection-match = "${c.mauve}ff";
        border = "${c.mauve}ff";
      };
      border = {
        width = 2;
        radius = 12;
      };
    };
  };

  services.mako = {
    enable = true;
    settings = {
      font = "${c.uiFont} 11";
      background-color = "#${c.base}";
      text-color = "#${c.text}";
      border-color = "#${c.mauve}";
      progress-color = "over #${c.surface0}";
      border-size = 2;
      border-radius = 10;
      padding = "12";
      margin = "10";
      width = 360;
      default-timeout = 5000;
      icons = true;
      max-icon-size = 48;
      "urgency=high" = {
        border-color = "#${c.peach}";
        default-timeout = 0;
      };
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      image = "${import ./wallpaper.nix { inherit pkgs; }}";
      scaling = "fill";
      font = c.font;
      indicator-radius = 90;
      indicator-thickness = 8;
      show-failed-attempts = true;
      color = c.base;
      inside-color = "${c.base}cc";
      inside-clear-color = "${c.base}cc";
      inside-ver-color = "${c.base}cc";
      inside-wrong-color = "${c.base}cc";
      ring-color = c.surface1;
      ring-clear-color = c.yellow;
      ring-ver-color = c.blue;
      ring-wrong-color = c.red;
      key-hl-color = c.mauve;
      bs-hl-color = c.maroon;
      line-color = "00000000";
      line-clear-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
      separator-color = "00000000";
      text-color = c.text;
      text-clear-color = c.text;
      text-ver-color = c.text;
      text-wrong-color = c.red;
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
}
