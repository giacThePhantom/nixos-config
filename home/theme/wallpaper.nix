# Wallpaper generated from the palette: the theme's --bg-gradient
# (135deg, bg -> bgSecondary -> bgTertiary), dithered to avoid banding.
{ pkgs, colors }:
pkgs.runCommand "wallpaper.png" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
  magick \( xc:'#${colors.bg}' xc:'#${colors.bgSecondary}' xc:'#${colors.bgTertiary}' +append \
      -filter triangle -resize '512x1!' \) -write mpr:clut +delete \
    -size 3840x2160 -depth 16 -define gradient:angle=135 gradient:black-white \
    mpr:clut -clut -ordered-dither o8x8,256 -depth 8 $out
''
