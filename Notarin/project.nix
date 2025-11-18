{
  pkgs,
  lib,
  system,
  ...
}: let
  crane = builtins.getFlake "github:ipetkov/crane/0cea393fffb39575c46b7a0318386467272182fe";
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
  checks.${system}.clippy = craneLib.cargoClippy {
    src = ./ocicat;
    cargoArtifacts = craneLib.buildDepsOnly {
      src = ./ocicat;
    };
    cargoClippyExtraArgs = "-- --deny warnings";
  };
}
