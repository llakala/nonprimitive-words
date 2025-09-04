{
  description = "Development environment with uv and Python 3.13";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python313
            uv
            bc
            stdenv.cc.cc.lib
            zlib
            glibc
          ];

          shellHook = ''
            echo "Python 3.13 development environment"
            echo "Python version: $(python --version)"
            echo "uv version: $(uv --version)"
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib:${pkgs.glibc}/lib:$LD_LIBRARY_PATH"
          '';
        };
      });
}