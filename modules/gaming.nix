# Gaming: Steam (native games + Proton) and Lutris (EA app, GOG, Battle.net...
# through Wine/Proton). 32-bit graphics drivers are enabled in hardware/nvidia.nix.
# Drop `gaming` from the host (hosts/nixos) to remove it all.
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      # Steam downloads Valve's Proton itself. For GE-Proton (newer game fixes,
      # +1.5 GiB) add: extraCompatPackages = [ pkgs.proton-ge-bin ];
      programs.steam.enable = true;

      # Raises CPU performance while a game runs: Steam launch option
      # `gamemoderun %command%`; in Lutris, System options > Enable Feral GameMode
      programs.gamemode.enable = true;

      # Lutris runs Windows games with its own GE-Proton/umu runtime, which it
      # downloads on first use into ~/.local/share/lutris
      environment.systemPackages = [ pkgs.lutris ];
    };
}
