# Opt-in: sioyek, a PDF viewer made for papers: click a citation, figure or
# equation reference to jump there (or preview it) and back, "portals" that
# keep a figure on screen while you read about it, highlights and bookmarks
# searchable across every PDF, a ruler for the line you're reading, SyncTeX.
# Becomes the default for PDFs; zathura stays for quick looks. +300 MiB (Qt).
# Enable it in hosts/.
{ config, ... }:
let
  inherit (config) colors fonts;
in
{
  flake.modules.homeManager.sioyek =
    { lib, ... }:
    let
      # sioyek wants colours as "r g b" floats from 0 to 1
      rgb =
        hex:
        lib.concatMapStringsSep " " (i: toString (lib.fromHexString (builtins.substring i 2 hex) / 255.0)) [
          0
          2
          4
        ];
    in
    {
      programs.sioyek = {
        enable = true;
        config = {
          # Pages in the palette (like zathura's recolouring): toggle back
          # to the original colours with the custom colour command
          startup_commands = [ "toggle_custom_color" ];
          custom_background_color = rgb colors.bg;
          custom_text_color = rgb colors.textSecondary;
          background_color = rgb colors.bgInput;
          page_separator_color = rgb colors.bgTertiary;
          text_highlight_color = rgb colors.accent;
          search_highlight_color = rgb colors.warning;
          link_highlight_color = rgb colors.infoText;
          visual_mark_color = "${rgb colors.accentLight} 0.15"; # the reading ruler
          status_bar_color = rgb colors.bgCard;
          status_bar_text_color = rgb colors.text;
          ui_font = fonts.ui;
          font_size = "15";
        };
        # F8 is plain inverted colours by default; make it the palette
        bindings.toggle_custom_color = "<f8>";
      };

      xdg.mimeApps.defaultApplications."application/pdf" = lib.mkForce "sioyek.desktop";
    };
}
