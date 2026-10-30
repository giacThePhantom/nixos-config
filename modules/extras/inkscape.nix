# Opt-in: Inkscape, for finishing figures (SVG/PDF from R or matplotlib) and
# posters. Enable it in hosts/.
{
  flake.modules.homeManager.inkscape =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.inkscape ];
    };
}
