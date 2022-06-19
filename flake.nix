{
  description = "siil.mikroskeem.eu box";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
    impermanence.url = "github:nix-community/impermanence/master";
  };

  outputs = { self, nixpkgs, flake-utils, impermanence }:
    let
      importPkgs = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      nixosModules.nixpkgsCommon = { lib, pkgs, ... }: {
        nix.nixPath = [
          "nixpkgs=${nixpkgs.outPath}"
        ] ++ lib.optionals pkgs.stdenv.isLinux [
          "nixpkgs/nixos=${nixpkgs.outPath}/nixos"
        ];
        nix.registry.nixpkgs.flake = nixpkgs;
      };

      nixosModules.impermanenceConfig = import ./modules/impermanence.nix;

      nixosConfigurations."markv" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.nixpkgsCommon
          self.nixosModules.impermanenceConfig
          impermanence.nixosModules.impermanence
          ./systems/markv
        ];
        specialArgs = {
          pkgs = importPkgs system;
        };
      };
    };
}
