# Launcher, notifications and lock screen config. The daemons themselves are
# started from the river init (see river.nix).
{
  pkgs,
  colors,
  fonts,
  ...
}:
let
  c = colors;
in
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "${fonts.ui}:size=12,${fonts.icons}:size=12";
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
        background = "${c.bg}f2";
        text = "${c.text}ff";
        prompt = "${c.textSecondary}ff";
        placeholder = "${c.textMuted}ff";
        input = "${c.text}ff";
        match = "${c.accent}ff";
        selection = "${c.bgSecondary}ff";
        selection-text = "${c.text}ff";
        selection-match = "${c.accent}ff";
        border = "${c.accent}ff";
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
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      image = "${import ./theme/wallpaper.nix { inherit pkgs colors; }}";
      scaling = "fill";
      font = fonts.mono;
      indicator-radius = 90;
      indicator-thickness = 8;
      show-failed-attempts = true;
      color = c.bg;
      inside-color = "${c.bg}cc";
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
}
