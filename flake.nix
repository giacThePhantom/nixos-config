{
  description = "NixOS + home-manager configuration of giacthephantom";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Not in nixpkgs; upstream flake pinned to a release tag. It keeps its own
    # nixpkgs: its pinned dependency hashes only match the pnpm it was made with.
    rencal.url = "github:t4t5/rencal/v0.8.1";
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    {
      # sudo nixos-rebuild switch --flake ~/.config/nixos#nixos
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos/configuration.nix
          ./system/desktop.nix
          ./system/nvidia.nix
          ./system/storage.nix

          home-manager.nixosModules.home-manager
          {
            # One nixpkgs for system and home, no second evaluation
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.giacthephantom = import ./home/home.nix;
          }
        ];
      };
    };
}
