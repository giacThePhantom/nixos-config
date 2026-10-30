# Bluetooth: headphones, mice, keyboards. Pair and connect in the terminal
# with bluetui (Super+D > Setup > Bluetooth). Audio devices then show up in
# the mixer and the media panel through PipeWire.
{
  flake.modules.nixos.bluetooth = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  flake.modules.homeManager.bluetooth =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.bluetui ];
    };
}
