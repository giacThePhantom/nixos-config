# The palette for apps that draw their own UI instead of using GTK:
# renCal, Telegram and Spotify.
{ config, inputs, ... }:
let
  inherit (config) colors;
in
{
  flake.modules.homeManager.theme =
    {
      pkgs,
      lib,
      ...
    }:
    let
      c = colors;
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      imports = [ inputs.spicetify-nix.homeManagerModules.default ];

      # renCal: a user theme (Settings > Themes > Custom), reloaded live on change.
      # Most surfaces derive from these primitives; tinting with white gives the
      # same translucent "glass" cards as the dashboard.
      xdg.configFile."rencal/themes/system.css".text = ''
        /* @name System */
        /* @appearance dark */
        --background: #${c.bg};
        --foreground: #${c.text};
        --muted-foreground: #${c.textMuted};
        --placeholder-foreground: #${c.textPlaceholder};
        --surface-tint: #ffffff;
        --sidebar: #${c.bgInput};
        --primary: #${c.accent};
        --primary-foreground: #ffffff;
        --ring: #${c.accent};
        --today: #${c.accentLight};
        --brand: #${c.gradientStart};
        --success: #${c.success};
        --warning: #${c.warning};
        --destructive: #${c.danger};
      '';

      # renCal rewrites its config.toml when settings change, so it can't be a
      # read-only managed file: select the theme only when there is no config yet.
      home.activation.rencalTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        config="''${XDG_CONFIG_HOME:-$HOME/.config}/rencal/config.toml"
        if [ ! -e "$config" ]; then
          run mkdir -p "$(dirname "$config")"
          run sh -c 'printf "[theme]\nmode = \"single\"\nsingle = \"user:system\"\n" > "$1"' _ "$config"
        fi
      '';

      # The calendars themselves: caldir's default is ~/caldir, with no
      # environment variable to move it, and renCal rewrites this file too
      # (keeping lines it doesn't know). Point it into XDG data when nothing
      # would be lost: no config yet, or the default with no ~/caldir to move
      # (docs/11-making-it-yours.md has the one-time move).
      home.activation.caldirDataDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        config="''${XDG_CONFIG_HOME:-$HOME/.config}/caldir/config.toml"
        line='calendar_dir = "~/.local/share/caldir"'
        if [ ! -e "$config" ]; then
          run mkdir -p "$(dirname "$config")"
          run sh -c 'printf "%s\n" "$2" > "$1"' _ "$config" "$line"
        elif [ ! -e "$HOME/caldir" ] && ! grep -q '^calendar_dir' "$config"; then
          run sh -c 'printf "%s\n" "$2" >> "$1"' _ "$config" "$line"
        elif [ ! -e "$HOME/caldir" ] && grep -q '^calendar_dir = "~/caldir"' "$config"; then
          run sed -i "s|^calendar_dir = .*|$line|" "$config"
        fi
      '';

      # Telegram: its built-in Night theme with Night's grey-blues swapped for
      # the palette (every occurrence of a colour, its translucent variants
      # included; status and name colours stay). Telegram keeps the selected
      # theme in its encrypted data, so it is loaded once by hand
      # (docs/08-applications.md), and again after a palette change.
      xdg.configFile."telegram/system.tdesktop-theme".source =
        let
          swap = {
            # backgrounds
            "17212b" = c.bg;
            "0e1621" = c.bgInput;
            "182533" = c.bgCard; # incoming messages
            "16222d" = c.bgCard; # tooltips
            "242f3d" = c.bgCard; # title bar, inputs
            "1f2936" = c.bgCard;
            "1b2734" = c.bgCard;
            "182433" = c.bgCard;
            "232e3c" = c.bgTertiary; # hover
            "24303d" = c.bgTertiary;
            "202b36" = c.bgTertiary;
            "1f2c39" = c.bgTertiary;
            "1d2a39" = c.bgTertiary;
            "202b37" = c.bgTertiary;
            "202b38" = c.bgTertiary;
            "1f2934" = c.bgTertiary;
            "1c2835" = c.bgTertiary;
            "1d2b3a" = c.bgTertiary;
            "25303e" = c.bgTertiary;
            "2c3847" = c.bgTertiary;
            "2d3a49" = c.bgTertiary;
            "223143" = c.bgSecondary; # ripples
            "27323f" = c.bgSecondary;
            "25313d" = c.bgSecondary;
            "222f3e" = c.bgSecondary;
            "243446" = c.bgSecondary;
            "2b3c4f" = c.bgSecondary;
            "2b5278" = c.bgSecondary; # outgoing messages, selected chat
            "315a80" = c.bgSecondary;
            "232f39" = c.borderHeavy; # separators
            "313c49" = c.borderHeavy;
            # text
            "f5f5f5" = c.text;
            "e9ecf0" = c.text;
            "e9e8e8" = c.text;
            "e9e9e9" = c.text;
            "ebebeb" = c.text;
            "eeeeee" = c.text;
            "e4ecf2" = c.text;
            "91a3b5" = c.textSecondary;
            "7c90a4" = c.textSecondary;
            "8495a9" = c.textSecondary;
            "708499" = c.textMuted;
            "677a8b" = c.textMuted;
            "6d7f8f" = c.textMuted;
            "7f91a4" = c.textMuted;
            "8696a8" = c.textMuted;
            "72879b" = c.textMuted;
            "768c9e" = c.textMuted;
            "6c7883" = c.textMuted;
            "6d7883" = c.textPlaceholder;
            "4f5b67" = c.textPlaceholder;
            # accent: fills
            "5288c1" = c.accent;
            "2f6ea5" = c.accent;
            "4082bc" = c.accent;
            "3983c3" = c.accent;
            "4a81bc" = c.accent;
            "2e70a5" = c.accent;
            "6396cb" = c.accent;
            "3f96d0" = c.accent;
            "4c9ce2" = c.accent;
            "488fc9" = c.accent;
            "3476ab" = c.accentHover;
            "3b7cb1" = c.accentHover;
            "489ed7" = c.accentHover;
            "54a4e9" = c.accentHover;
            # accent: text, links and icons on dark backgrounds
            "6ab3f3" = c.accentLight;
            "6ab2f2" = c.accentLight;
            "70baf5" = c.accentLight;
            "73b9f5" = c.accentLight;
            "72bcfd" = c.accentLight;
            "64b9fa" = c.accentLight;
            "5eb5f7" = c.accentLight;
            "63b6ff" = c.accentLight;
            "65b6fc" = c.accentLight;
            "83caff" = c.accentLight;
            "6bbfff" = c.accentLight;
            "71bafa" = c.accentLight;
            "5598db" = c.accentLight;
            "559be0" = c.accentLight;
            "429bdb" = c.accentLight;
            "549cd7" = c.accentLight;
            "51a0e5" = c.accentLight;
          };
          sedScript = lib.concatStrings (lib.mapAttrsToList (from: to: "s/#${from}/#${to}/g\n") swap);
        in
        pkgs.runCommand "system.tdesktop-theme"
          {
            nativeBuildInputs = [
              pkgs.unzip
              pkgs.zip
              pkgs.imagemagick
            ];
          }
          ''
            unzip -q ${pkgs.telegram-desktop.unwrapped.src}/Telegram/Resources/night.tdesktop-theme colors.tdesktop-theme
            sed -i -f ${pkgs.writeText "telegram-palette.sed" sedScript} colors.tdesktop-theme
            # the chat background: plain bg, like the rest of the desktop
            magick -size 1x1 xc:'#${c.bg}' background.png
            zip -q -X $out colors.tdesktop-theme background.png
          '';

      # Spotify, patched by Spicetify with a colour scheme from the palette
      programs.spicetify = {
        enable = true;
        theme = spicePkgs.themes.default;
        customColorScheme = {
          text = c.text;
          subtext = c.textSecondary;
          main = c.bg;
          sidebar = c.bgInput;
          player = c.bgInput;
          card = c.bgCard;
          shadow = c.bgInput;
          selected-row = c.textSecondary;
          button = c.accent;
          button-active = c.accentLight;
          button-disabled = c.textPlaceholder;
          tab-active = c.bgSecondary;
          notification = c.bgSecondary;
          notification-error = c.danger;
          misc = c.bgTertiary;
        };
      };
    };
}
