# Wallpapers and logo images generated from the palette. `plain` is the
# theme's --bg-gradient (135deg, bg -> bgSecondary -> bgTertiary), dithered to
# avoid banding; `branded` draws the EnjoyTheLab logo and name
# (_branding/wallpaper.svg) over it; `lock` centres the logo, for swaylock to
# draw its ring around, with the name below; `icon` is the logo alone
# (_branding/icon.svg), transparent, for fastfetch. The SVGs get their colours
# and font from the palette.
{
  pkgs,
  colors,
  fonts,
}:
let
  plain = pkgs.runCommand "wallpaper.png" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
    magick \( xc:'#${colors.bg}' xc:'#${colors.bgSecondary}' xc:'#${colors.bgTertiary}' +append \
        -filter triangle -resize '512x1!' \) -write mpr:clut +delete \
      -size 3840x2160 -depth 16 -define gradient:angle=135 gradient:black-white \
      mpr:clut -clut -ordered-dither o8x8,256 -depth 8 $out
  '';

  # @NAME@ in the SVGs: a palette colour, or fontMono
  names = builtins.attrNames colors;
  fill =
    name: file:
    pkgs.writeText name (
      builtins.replaceStrings (map (n: "@${n}@") names ++ [ "@fontMono@" ]) (
        map (n: "#${colors.${n}}") names ++ [ fonts.mono ]
      ) (builtins.readFile file)
    );

  # The name as the web app writes it: "Enjoy" in the logo's cyan, "TheLab"
  # in its light blue. Baseline below swaylock's ring (radius 118 at 1080p).
  lockName = pkgs.writeText "lock-name.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="3840" height="2160">
      <text x="1920" y="1440" text-anchor="middle" font-family="${fonts.mono}"
        font-weight="bold" font-size="72"><tspan fill="#${colors.logoEnjoy}">Enjoy</tspan><tspan
        fill="#${colors.infoLight}">TheLab</tspan></text>
    </svg>
  '';

  render =
    name: script:
    pkgs.runCommand name
      {
        nativeBuildInputs = [
          pkgs.librsvg
          pkgs.imagemagick
        ];
        FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ pkgs.jetbrains-mono ]; };
      }
      ''
        export HOME=$TMPDIR # fontconfig wants a cache directory
        ${script}
      '';

  branded = render "wallpaper-branded.png" ''
    rsvg-convert -w 3840 -h 2160 ${fill "wallpaper.svg" ./_branding/wallpaper.svg} -o logo.png
    magick ${plain} logo.png -composite $out
  '';

  # 360 px at 4K: inside the ring (inner radius 106 at 1080p) with a margin
  lock = render "wallpaper-lock.png" ''
    rsvg-convert -w 360 -h 360 ${fill "icon.svg" ./_branding/icon.svg} -o icon.png
    rsvg-convert -w 3840 -h 2160 ${lockName} -o name.png
    magick ${plain} icon.png -gravity center -composite name.png -composite $out
  '';

  icon = render "logo.png" ''
    rsvg-convert -w 512 -h 512 ${fill "icon.svg" ./_branding/icon.svg} -o $out
  '';
in
{
  inherit
    plain
    branded
    lock
    icon
    ;
}
