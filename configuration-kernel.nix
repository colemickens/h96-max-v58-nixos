{ pkgs, lib, ... }:
{
  boot.kernelPackages = lib.mkForce (pkgs.linuxKernel.packagesFor (pkgs.callPackage ./kernel.nix {}));
  boot.kernelParams = pkgs.lib.mkForce [
    "console=ttyS2,1500000n8"
    "loglevel=7"
  ];
  boot.kernelPatches = (import ./kernelPatches.nix { fetchpatch2 = pkgs.fetchpatch2; });
}
