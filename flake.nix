{
  description = "OrcaSlicer wrapper flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

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
      default = pkgs.callPackage ./package.nix {
        withNvidiaGLWorkaround = true;
      };

      no-nvidia-workaround = pkgs.callPackage ./package.nix {
        withNvidiaGLWorkaround = false;
      };
    });

    apps = forAllSystems (pkgs: {
      default = {
        type = "app";
        program = "${pkgs.callPackage ./package.nix {withNvidiaGLWorkaround = true;}}/bin/orca-slicer";
      };

      no-nvidia-workaround = {
        type = "app";
        program = "${pkgs.callPackage ./package.nix {withNvidiaGLWorkaround = false;}}/bin/orca-slicer";
      };
    });
  };
}
