# eww dashboard: layout in eww/eww.yuck, style in eww/eww.scss, colours
# generated from palette.nix. The daemon is started by river init.
{ lib, ... }:
let
  c = import ./palette.nix;
  colors = lib.concatStrings (
    lib.mapAttrsToList (name: value: "\$${name}: #${value};\n") (
      lib.filterAttrs (n: _: n != "font" && n != "uiFont") c
    )
  );
in
{
  xdg.configFile = {
    "eww/eww.yuck".source = ./eww/eww.yuck;
    "eww/eww.scss".source = ./eww/eww.scss;
    "eww/colors.scss".text = colors;
  };
}
