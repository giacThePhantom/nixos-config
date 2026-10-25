{
  description = "NixOS + home-manager configuration of giacthephantom";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    {
      # sudo nixos-rebuild switch --flake ~/.config/nixos#nixos
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos/configuration.nix
          ./system/desktop.nix
          ./system/nvidia.nix

          home-manager.nixosModules.home-manager
          {
            # One nixpkgs for system and home, no second evaluation
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.giacthephantom = import ./home/home.nix;
          }
        ];
      };
    };
}
