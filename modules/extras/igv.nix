# Opt-in: IGV, the Integrative Genomics Viewer (reads, variants, tracks on a
# genome). Java. Enable it in hosts/.
{
  flake.modules.homeManager.igv =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.igv ];
      # IGV ships no menu entry
      xdg.desktopEntries.igv = {
        name = "IGV";
        genericName = "Genome browser";
        exec = "igv %F";
        icon = "applications-science";
        categories = [
          "Science"
          "Biology"
        ];
      };
    };
}
