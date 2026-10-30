# The palette outside the desktop session: text consoles (TTYs) and the
# tuigreet login screen.
{ config, ... }:
let
  inherit (config) colors;
in
{
  flake.modules.nixos.theme =

    let
      c = colors;
    in
    {
      # Linux console palette, in ANSI order (black red green yellow blue
      # magenta cyan white, then the bright variants). Colour 0 is also the
      # console background. Same mapping as the foot terminal.
      console.colors = with c; [
        bgCard
        danger
        success
        warning
        gradientStart
        accent
        info
        textSecondary
        textPlaceholder
        dangerText
        successText
        warningText
        infoText
        accentLight
        infoLight
        text
      ];
    };
}
