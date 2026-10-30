# The palette for apps that draw their own UI instead of using GTK:
# renCal and Spotify.
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
