{
  description = "Official OrcaSlicer AppImage wrapped for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux"];

    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (
        system:
          f (import nixpkgs {
            inherit system;
            config.allowUnfree = false;
          })
      );
  in {
    packages = forAllSystems (pkgs: {
      default = pkgs.callPackage ./package.nix {};
    });

    apps = forAllSystems (pkgs: let
      package = pkgs.callPackage ./package.nix {};
    in {
      default = {
        type = "app";
        program = pkgs.lib.getExe package;
        meta = package.meta;
      };
    });
  };
}
