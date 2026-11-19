# This machine: its hardware and the features it runs. Each name is a module
# some file under modules/ defines (`flake.modules.nixos.NAME` for the system,
# `flake.modules.homeManager.NAME` for the user); drop one from a list to
# remove that feature, add one from extras/ to get it. Without an NVIDIA GPU
# drop `nvidia`; adapt or drop `storage` (your drives).
{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  configurations.nixos.${config.settings.hostname}.module = {
    imports = [
      ./_hardware-configuration.nix
    ]
    ++ (with nixos; [
      base
      home
      theme
      river
      nvidia
      storage
      gaming
      dev
      bluetooth
      apps
      passwords
      bio
      data
      cluster
      clean-home
      containers
      home-row-mods
      # On a laptop add: laptop (both lists)
      # Opt-in (extras/): containers (Podman + Apptainer, +510 MiB),
      # accessibility (screen reader, magnifier; both lists, +760 MiB)
    ]);

    home-manager.users.${config.settings.user.name}.imports = with homeManager; [
      base
      theme
      river
      dashboard
      scripts
      desktop
      launcher
      terminal
      editor
      apps
      mail
      dev
      bluetooth
      passwords
      bio
      data
      cluster
      writing
      clean-home
      office
      inkscape
      sioyek
      # Opt-in (extras/), with what each adds: office (OnlyOffice, +1.3 GiB) OR
      # libreoffice (+1.7 GiB, for Zotero's official plugin), igv (+640 MiB),
      # pymol (+300 MiB), inkscape (+500 MiB), backup (nightly restic, see
      # extras/backup.nix), syncthing (+30 MiB), sioyek (a PDF viewer made
      # for papers, +300 MiB), accessibility (both lists)
    ];

    nixpkgs.hostPlatform = "x86_64-linux";

    # Version this machine was installed with; never change it (it is not the
    # NixOS version you run, see `man configuration.nix`).
    system.stateVersion = "26.05";
  };
}
