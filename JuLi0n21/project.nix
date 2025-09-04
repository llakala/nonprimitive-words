{ pkgs, lib, system, ... }:
{
  packages.${system} = {
    strawberry = pkgs.buildGoModule rec {
      pname = "strawberry";
      version = "1.0.0";
      src = ./strawberry;

      vendorHash = null;

      # Binary that gets run when doing `nix run .#strawberry`. Same as the name
      # of the go module
      meta.mainProgram = "nonprimitivewords";
    };
  };
}
