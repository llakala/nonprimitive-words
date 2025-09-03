{
  pkgs,
  lib,
  crane,
  system,
  ...
}: let
  craneLib = crane.mkLib pkgs;
in {
  packages.${system} = let
    ocicatCargo = builtins.fromTOML (builtins.readFile ./ocicat/Cargo.toml);
  in {
    ${ocicatCargo.package.name} = craneLib.buildPackage {
      src = ./ocicat;
      nativeBuildInputs = with pkgs; [
        pkg-config
      ];
      meta = {
        description = "A rust algorithm solving A239019.";
        maintainers = [lib.maintainers.Notarin];
      };
    };
  };
}
