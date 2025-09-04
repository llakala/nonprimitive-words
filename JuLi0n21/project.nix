{ pkgs, lib, system, ... }:
{
  packages.${system} = {
    strawberry = pkgs.buildGoModule rec {
      pname = "strawberry";
      version = "1.0.0";
      src = ./strawberry;

      vendorHash = null;
    };
  };
}
