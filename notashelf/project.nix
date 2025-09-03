{
  pkgs,
  lib,
  ...
}: {
  packages.x86_64-linux = let
    name = "steampunk";
  in {
    ${name} = pkgs.stdenv.mkDerivation {
      name = name;
      src = ./.;

      buildPhase = ''
        runHook preBuild

        ${lib.getExe pkgs.nasm} -O3 -felf64 main.asm
        ld -s -o main main.o

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin
        cp main $out/bin

        runHook postInstall
      '';

      meta = {
        mainProgram = "main";
      };
    };
  };
}
