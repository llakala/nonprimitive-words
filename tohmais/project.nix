{
  pkgs,
  system,
  ...
}: {
  packages.${system}.tram = pkgs.stdenv.mkDerivation {
    name = "tram";
    src = ./.;
    nativeBuildInputs = [
      pkgs.zig.hook
    ];
    buildPhase = ''
      runHook preBuild

      zig build

      runHook postBuild
    '';
    dontUseZigCheck = true;

    meta = {
      mainProgram = "tohmais";
    };
  };
  devShells.${system}.tram = pkgs.mkShell {
    buildInputs = [
      pkgs.zig
      pkgs.zls
    ];
  };
}
