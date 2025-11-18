{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: (
    # Provides the variable `system`. More technically, it creates a copy per system, then merges them all together
    builtins.foldl' (acc: elem: nixpkgs.lib.recursiveUpdate acc elem) {} (
      builtins.map (
        system: let
          # Prelude
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (pkgs) lib;

          # Flake-wide utilities
          utils = let
            utilsDir = ./nix;
          in {
            recursiveMerge = import "${utilsDir}/recursiveMerge.nix" specialArgs;
            shellHook = builtins.readFile "${utilsDir}/shellHook.sh";
            mergedProjects = import "${utilsDir}/projectLoading.nix" specialArgs;
            flakePath = ./.;
          };

          # specialArgs are arguments which will be passed to each project.nix
          # If you have dependencies in your project you wish to use, add them here
          specialArgs = {
            inherit system self pkgs lib utils;
          };
        in
          utils.recursiveMerge [
            {
              formatter.${system} = pkgs.callPackage ./nix/treefmt.nix {};
              checks.${system}.formatting = self.formatter.${system};
              devShells.${system}.default = pkgs.mkShell {
                inherit (utils) shellHook;
              };
            }
            # Pull in all projects
            utils.mergedProjects
          ]
      )
      # Universally supported systems
      ["x86_64-linux"]
    )
  );
}
