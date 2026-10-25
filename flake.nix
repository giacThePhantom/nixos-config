{
  description = "Minimal river desktop on NixOS + home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Not in nixpkgs; upstream flake pinned to a release tag, built with our
    # nixpkgs (home/default.nix pins the JS dependency hash for our pnpm).
    rencal = {
      url = "github:t4t5/rencal/v0.8.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Spotify with a palette colour scheme (home/theme/apps.nix)
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      settings = import ./settings.nix;
      palette = import ./palette.nix;
      # Extra arguments every system and home module receives
      args = {
        inherit inputs settings;
        inherit (palette) colors fonts;
      };
    in
    {
      # sudo nixos-rebuild switch --flake ~/.config/nixos (the `rebuild` alias)
      nixosConfigurations.${settings.hostname} = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = args;
        modules = [
          ./hosts/nixos/configuration.nix
          ./system/desktop.nix
          ./system/nvidia.nix
          ./system/storage.nix
          ./system/gaming.nix
          ./system/theme.nix

          home-manager.nixosModules.home-manager
          {
            # One nixpkgs for system and home, no second evaluation
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = args;
            home-manager.users.${settings.user.name} = import ./home;
          }
        ];
      };
    };
}
