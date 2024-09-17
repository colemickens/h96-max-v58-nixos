{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    disko.url = "github:nix-community/disko";
  };
  outputs = inputs: rec {
     overlays = {
      default = (final: prev: {
        uboot_h96maxv58 = prev.callPackage ./u-boot/default.nix {};
      });
    };
    packages = {
      aarch64-linux = {
        example-image-builder = nixosConfigurations.example.config.system.build.diskoImagesScript;
      };
    };
    nixosModules = {
      kernel = import ./module-kernel.nix;
      device-tree = import ./module-device-tree.nix;
      firmware = import ./module-firmware.nix;
    };
    nixosConfigurations = {
      example = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          (import ./configuration-example.nix { inherit inputs; })
        ];
      };
    };
  };
}
