{ inputs }:

{ pkgs, lib, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko

    inputs.self.outputs.nixosModules.kernel
    inputs.self.outputs.nixosModules.device-tree
    inputs.self.outputs.nixosModules.firmware
  ];
  config = {
    system.stateVersion = "24.05";
    nixpkgs.hostPlatform = "aarch64-linux";

    environment.systemPackages = with pkgs; [
      vim
      helix
      git
      pciutils
      usbutils
      alsa-utils
    ];
    nix.settings = {
      experimental-features = lib.mkDefault "nix-command flakes";
      trusted-users = [ "root" "@wheel" ];
    };
    nixpkgs.overlays = [
      inputs.self.outputs.overlays.default
    ];
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "armbian-firmware"
      "armbian-firmware-unstable"
    ];

    services.logind.extraConfig = ''
      RuntimeDirectorySize=50%
    '';

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    users.users."default" = {
      password = "nixosisbestos";
      isNormalUser = true;
      extraGroups = [ "wheel" "dialout" "input" "video" "audio" ];
    };
    security.sudo.wheelNeedsPassword = false;

    # disko only after this
    disko = {
      memSize = 4096;
      imageBuilder.extraPostVM = ''
        (
          set -x
          disk=$out/disk0.raw
          ${pkgs.coreutils}/bin/dd if=${pkgs.uboot_h96maxv58}/u-boot-rockchip.bin of=$disk seek=64 bs=512 conv=notrunc
          ${pkgs.zstd}/bin/zstd --compress $disk
          rm $disk
        )
      '';
      devices.disk.disk0 = {
        type = "disk";
        imageSize = "4G";
        content = {
          type = "gpt";
          partitions = {
            empty = {
              priority = 1;
              start = "34";
              alignment = 1;
              end = "63";
            };
            firmware = {
              priority = 2;
              start = "64";
              size = "64M";
              alignment = 1;
            };
            ESP = {
              priority = 3;
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            rootfs = {
              priority = 4;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };

  };
}
