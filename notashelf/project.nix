{
  pkgs,
  lib,
  ...
}: {
  packages.x86_64-linux = {
    "steampunk" = let
      fs = lib.fileset;
    in
      pkgs.stdenv.mkDerivation {
        pname = "steampunk";
        version = "0-unstable-2025-09-03";

        src = fs.toSource {
          root = ./.;
          fileset = fs.unions [./main.asm];
        };

        buildPhase = ''
          runHook preBuild

          ${lib.getExe pkgs.nasm} -O3 -felf64 main.asm
          ld -s -o steampunk main.o

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin
          install -Dm755 steampunk $out/bin

          runHook postInstall
        '';

        meta = {
          description = "x86-64 assembly implementation for OEIS A239019";
          mainProgram = "steampunk";
          maintainers = [lib.maintainers.NotAShelf];
        };
      };
  };
}
