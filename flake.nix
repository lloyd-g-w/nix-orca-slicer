{
  description = "Run latest stable OrcaSlicer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (
        system:
          f system (import nixpkgs {
            inherit system;
            config.allowUnfree = false;
          })
      );
  in {
    packages = forAllSystems (system: pkgs: {
      default = pkgs.orca-slicer.override {
        withNvidiaGLWorkaround = true;
      };

      no-nvidia-workaround = pkgs.orca-slicer.override {
        withNvidiaGLWorkaround = false;
      };
    });

    apps = forAllSystems (system: pkgs: {
      default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/orca-slicer";
      };

      no-nvidia-workaround = {
        type = "app";
        program = "${self.packages.${system}.no-nvidia-workaround}/bin/orca-slicer";
      };
    });

    formatter = forAllSystems (_system: pkgs: pkgs.nixfmt-rfc-style);
  };
}
