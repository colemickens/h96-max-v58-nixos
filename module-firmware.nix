{ pkgs, lib, ... }:
{
  hardware.firmware = [
    (pkgs.armbian-firmware.overrideAttrs {
      src = pkgs.fetchFromGitHub {
        owner = "armbian";
        repo = "firmware";
        rev = "511deee7289cb9a5dee6ba142d18a09933d5ba00";
        hash = "sha256-l5/SEwrkM3nt7/xj1ejAaRwXIvYdlD5Yn8377paBq/k=";
      };
      compressFirmware = false;
    })
  ];
}
