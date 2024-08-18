{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-mesa.url = "github:K900/nixpkgs?ref=mesa-24.2";
  };
  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        flake-parts.flakeModules.easyOverlay
        ./flake-modules/udev-rules
        ./flake-modules/flash-scripts
      ];
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages = {
          ubootH96MaxV58 = pkgs.callPackage ./u-boot {};
          rkboot = pkgs.callPackage ./rkboot {};
        };
        _module.args.pkgs = import inputs.nixpkgs {
          config.allowUnfree = true;
          # config.allowUnsupportedSystem = true; # remove when https://github.com/NixOS/nixpkgs/pull/303370 is merged
          overlays = [
            inputs.self.overlays.default
          ];
          inherit system;
        };
        overlayAttrs = { inherit (config.packages) ubootH96MaxV58; };
      };
      flake = let
        images = {
          h96-max-v58 = (inputs.self.nixosConfigurations.h96-max-v58.extendModules {
            modules = [
              ./sd-image.nix
            ];
          }).config.system.build.sdImage;
        };
      in {
        packages = {
          x86_64-linux.h96-max-v58-image = images.h96-max-v58;
          aarch64-linux.h96-max-v58-image = images.h96-max-v58;
        };
        nixosModules = {
          mesa-24_2 = import ./mesa-24_2.nix {inputs=inputs;};

          base-config = import ./configuration.nix;
          device-tree = import ./device-tree.nix;
        };
        nixosConfigurations = {
          h96-max-v58 = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              "${nixpkgs}/nixos/modules/profiles/minimal.nix"
              inputs.self.nixosModules.mesa-24_2
              ./configuration.nix
              ./device-tree.nix
            ];
            specialArgs = { inherit inputs; };
          };
        };
      };
    };
}

