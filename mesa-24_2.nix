{ inputs }: 
{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: { mesa  = inputs.nixpkgs-mesa.outputs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.mesa; })
  ];
  hardware.opengl = {
    enable = true;
    # package = mesa-panthor.drivers;
  };
}

