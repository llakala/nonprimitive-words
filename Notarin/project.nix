{
  pkgs,
  crane,
  system,
  ...
}: let
  craneLib = crane.mkLib pkgs;
in {
  packages.${system} = {
    notarin-rust = craneLib.buildPackage {
      src = ./rust;
      nativeBuildInputs = with pkgs; [
        pkg-config
      ];
      meta = {
        description = "A rust algorithm solving A239019.";
        mainProgram = "A239019";
      };
    };
  };
}
