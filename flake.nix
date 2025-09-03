{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane";
  };

  outputs = {
    self,
    nixpkgs,
    treefmt-nix,
    crane,
    ...
  }: (
    # Provides the variable `system`. More technically, it creates a copy per system, then merges them all together
    builtins.foldl' (acc: elem: nixpkgs.lib.recursiveUpdate acc elem) {} (
      builtins.map (
        system: let
          # Prelude
          pkgs = nixpkgs.legacyPackages.${system};
          lib = pkgs.lib;

          # Flake-wide utilities
          utils = let
            utilsDir = ./nix;
          in {
            recursiveMerge = import "${utilsDir}/recursiveMerge.nix" specialArgs;
            shellHook = builtins.readFile "${utilsDir}/shellHook.sh";
            treefmt-config = treefmt-nix.lib.evalModule pkgs "${utilsDir}/treefmt.nix";
            mergedProjects = import "${utilsDir}/projectLoading.nix" specialArgs;
            flakePath = ./.;
          };

          # specialArgs are arguments which will be passed to each project.nix
          # If you have dependencies in your project you wish to use, add them here
          specialArgs = {
            inherit system self pkgs lib utils crane;
          };
        in
          {
            formatter.${system} = utils.treefmt-config.config.build.wrapper;
            devShells.${system}.default = pkgs.mkShell {
              shellHook = utils.shellHook;
            };
          }
          # Pull in all projects
          // utils.mergedProjects
      )
      # Universally supported systems
      ["x86_64-linux"]
    )
  );
}
