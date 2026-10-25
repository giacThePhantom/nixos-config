# eww dashboard panels (Super+A menu, see ../scripts/dash.sh). eww/ holds the
# layout (eww.yuck + one .yuck per panel) and style (eww.scss + one .scss per
# panel); colors.scss is generated here from the palette.
{ lib, colors, ... }:
{
  xdg.configFile = {
    eww = {
      source = ./eww;
      recursive = true;
    };
    "eww/colors.scss".text = lib.concatStrings (
      lib.mapAttrsToList (name: value: "\$${name}: #${value};\n") colors
    );
  };
}
