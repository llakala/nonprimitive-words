{
  description = "Flake for number substring programming environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = f:
      builtins.listToAttrs (map (system: {
          name = system;
          value = f system;
        })
        systems);
  in {
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      default = pkgs.stdenv.mkDerivation {
        pname = "nonprimative-words";
        version = "0.1.0";
        src = ./.;

        nativeBuildInputs = [pkgs.zig];

        buildPhase = ''
          zig build -Drelease-safe=true
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp zig-out/bin/* $out/bin/
        '';
      };
    });

    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      default = pkgs.mkShell {
        buildInputs = [
          pkgs.zig
          pkgs.zls
        ];
      };
    });
  };
}
