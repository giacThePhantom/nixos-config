# Opt-in: PyMOL (open-source build), molecular structures. Enable it in
# hosts/.
{
  flake.modules.homeManager.pymol =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.pymol ];
    };
}
