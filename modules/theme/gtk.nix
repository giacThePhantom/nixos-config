# Fonts, cursor and GTK theme; apps.nix here themes apps that have their own UI.
# Qt isn't themed: the one Qt app, Zoom, ships its own Qt and ignores the
# system theme (it has a dark mode in its settings); see the personalize skill.
{ config, ... }:
let
  inherit (config) colors fonts;
in
{
  flake.modules.homeManager.theme =
    {
      pkgs,
      ...
    }:
    let
      c = colors;

      # adw-gtk3 (GTK3) and libadwaita (GTK4) read these named colours, so every
      # GTK app follows the palette without a custom theme package.
      gtkCss = ''
        @define-color accent_color #${c.accentLight};
        @define-color accent_bg_color #${c.accent};
        @define-color accent_fg_color #ffffff;
        @define-color destructive_color #${c.dangerText};
        @define-color destructive_bg_color #${c.danger};
        @define-color destructive_fg_color #ffffff;
        @define-color success_color #${c.successText};
        @define-color success_bg_color #${c.success};
        @define-color warning_color #${c.warningText};
        @define-color warning_bg_color #${c.warning};
        @define-color error_color #${c.dangerText};
        @define-color error_bg_color #${c.danger};

        @define-color window_bg_color #${c.bg};
        @define-color window_fg_color #${c.text};
        @define-color view_bg_color #${c.bgInput};
        @define-color view_fg_color #${c.text};
        @define-color headerbar_bg_color #${c.bg};
        @define-color headerbar_fg_color #${c.text};
        @define-color headerbar_backdrop_color #${c.bg};
        @define-color sidebar_bg_color #${c.bgInput};
        @define-color sidebar_fg_color #${c.text};
        @define-color secondary_sidebar_bg_color #${c.bgInput};
        @define-color card_bg_color #${c.bgCard};
        @define-color card_fg_color #${c.text};
        @define-color dialog_bg_color #${c.bgTertiary};
        @define-color dialog_fg_color #${c.text};
        @define-color popover_bg_color #${c.bgTertiary};
        @define-color popover_fg_color #${c.text};
        @define-color thumbnail_bg_color #${c.bgCard};
        @define-color thumbnail_fg_color #${c.text};

        /* river asks every window to leave decorations to it (rules.nix), but
           GTK doesn't speak that protocol and draws its own: no shadows or
           rounded corners around tiled windows */
        window.csd,
        window.csd decoration {
          box-shadow: none;
          border-radius: 0;
        }
      '';

      # GTK 3's default title bar, on windows without a header bar of their own
      # (Thunar, xarchiver, dialogs): only a title, which river's border and
      # the bar already show, so it moves out of sight. Header bars carrying an
      # app's controls stay.
      gtk3Css = ''
        headerbar.default-decoration {
          margin-top: -100px;
        }
      '';

    in
    {

      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [
            fonts.mono
            fonts.iconsMono
          ];
          sansSerif = [
            fonts.ui
            fonts.icons
            "Noto Sans"
          ];
          serif = [ "Noto Serif" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };

      home.packages = with pkgs; [
        jetbrains-mono
        nerd-fonts.symbols-only
        inter
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        # Same letter widths as Word's fonts, so .docx files keep their line and
        # page breaks; fontconfig already maps the names (Calibri -> Carlito,
        # Cambria -> Caladea, Arial/Times/Courier -> Liberation)
        carlito
        caladea
        liberation_ttf
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
          # Folder icons in blue, close to the accent
          package = pkgs.papirus-icon-theme.override { color = "blue"; };
          name = "Papirus-Dark";
        };
        font = {
          name = fonts.ui;
          size = 11;
        };
        gtk3.extraCss = gtkCss + gtk3Css;
        gtk4.extraCss = gtkCss;
        # No minimise/maximise/close buttons in header bars: river tiles, and
        # Super+W closes. Only the app menu, where an app has one, stays.
        gtk3.extraConfig.gtk-decoration-layout = "menu:";
        gtk4.extraConfig.gtk-decoration-layout = "menu:";
      };
      # On Wayland GTK reads the button layout from here, not settings.ini
      dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "menu:";
    };
}
