{
  description = "NixOS System by MauroV";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = {self, nixpkgs, home-manager, darwin, ...}@inputs: let
    overlays = [];
    mkSystem = import ./lib/mksystem.nix {
        inherit overlays nixpkgs inputs;
    };

  in {
     nixosConfigurations.vm-aarch64 = mkSystem "vm-aarch64" {
        system = "aarch64-linux";
        user = "maurov";
    };
     nixosConfigurations.vm-aarch64-utm = mkSystem "vm-aarch64-utm" {
        system = "aarch64-linux";
        user = "maurov";
    };
  };
}
