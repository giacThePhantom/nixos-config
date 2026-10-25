# Fonts, GTK/Qt theme, cursor. Colours come from palette.nix.
{ pkgs, lib, config, ... }:
let
  c = import ./palette.nix;

  # adw-gtk3 (GTK3) and libadwaita (GTK4) read these named colours, so every
  # GTK app follows the palette without a custom theme package.
  gtkCss = ''
    @define-color accent_color #${c.pink};
    @define-color accent_bg_color #${c.mauve};
    @define-color accent_fg_color #ffffff;
    @define-color destructive_color #${c.maroon};
    @define-color destructive_bg_color #${c.red};
    @define-color destructive_fg_color #ffffff;
    @define-color success_color #${c.teal};
    @define-color success_bg_color #${c.green};
    @define-color warning_color #${c.yellow};
    @define-color warning_bg_color #${c.peach};
    @define-color error_color #${c.maroon};
    @define-color error_bg_color #${c.red};

    @define-color window_bg_color #${c.base};
    @define-color window_fg_color #${c.text};
    @define-color view_bg_color #${c.crust};
    @define-color view_fg_color #${c.text};
    @define-color headerbar_bg_color #${c.base};
    @define-color headerbar_fg_color #${c.text};
    @define-color headerbar_backdrop_color #${c.base};
    @define-color sidebar_bg_color #${c.crust};
    @define-color sidebar_fg_color #${c.text};
    @define-color secondary_sidebar_bg_color #${c.crust};
    @define-color card_bg_color #${c.mantle};
    @define-color card_fg_color #${c.text};
    @define-color dialog_bg_color #${c.surface0};
    @define-color dialog_fg_color #${c.text};
    @define-color popover_bg_color #${c.surface0};
    @define-color popover_fg_color #${c.text};
    @define-color thumbnail_bg_color #${c.mantle};
    @define-color thumbnail_fg_color #${c.text};
  '';

  # Qt: Fusion style + a colour scheme generated from the palette (qt5ct/qt6ct).
  # Order is QPalette's: WindowText Button Light Midlight Dark Mid Text
  # BrightText ButtonText Base Window Shadow Highlight HighlightedText Link
  # LinkVisited AlternateBase NoRole ToolTipBase ToolTipText PlaceholderText
  qtColors =
    roles:
    lib.concatMapStringsSep ", " (x: "#ff${x}") roles;
  qtScheme = ''
    [ColorScheme]
    active_colors=${qtColors (with c; [ text surface0 surface2 surface1 crust mantle text text text crust base crust mauve text pink lavender mantle mantle surface0 text overlay1 ])}
    inactive_colors=${qtColors (with c; [ text surface0 surface2 surface1 crust mantle text text text crust base crust surface1 text pink lavender mantle mantle surface0 text overlay1 ])}
    disabled_colors=${qtColors (with c; [ overlay0 surface0 surface2 surface1 crust mantle overlay0 overlay0 overlay0 crust base crust surface1 overlay0 overlay0 overlay0 mantle mantle surface0 overlay0 overlay0 ])}
  '';
  qtConf = version: {
    "qt${version}ct/colors/palette.conf".text = qtScheme;
    "qt${version}ct/qt${version}ct.conf".text = ''
      [Appearance]
      style=Fusion
      custom_palette=true
      color_scheme_path=${config.xdg.configHome}/qt${version}ct/colors/palette.conf
      icon_theme=Papirus-Dark
      standard_dialogs=default

      [Fonts]
      general="${c.uiFont},11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
      fixed="${c.font},11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
    '';
  };
in
{
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Inter" "Noto Sans" ];
      serif = [ "Noto Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    colorScheme = "dark";
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    font = {
      name = "Inter";
      size = 11;
    };
    gtk3.extraCss = gtkCss;
    gtk4.extraCss = gtkCss;
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
  };
  xdg.configFile = qtConf "5" // qtConf "6";
}
