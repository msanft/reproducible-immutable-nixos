{
  description = "Reproducible and Immutable NixOS Images";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          qemu-image = pkgs.callPackage ./image {
            platform = "qemu";
          };

          boot-uefi-qemu = pkgs.callPackage ./utils/boot-uefi-qemu.nix { };
        };
      }
    );
}
