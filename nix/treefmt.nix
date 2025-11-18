{
  treefmt-nix ?
    import (builtins.fetchGit {
      url = "https://github.com/numtide/treefmt-nix";
      rev = "5b4ee75aeefd1e2d5a1cc43cf6ba65eba75e83e4";
    }),
  lib,
  writeShellScriptBin,
  formats,
  treefmt,
  alejandra,
  mdformat,
  rustfmt,
  shellcheck,
  toml-sort,
}:
treefmt-nix.mkWrapper {
  inherit
    lib
    writeShellScriptBin
    treefmt
    formats
    alejandra
    mdformat
    rustfmt
    shellcheck
    toml-sort
    ;
} {
  projectRootFile = ".git/config";
  settings = {
    allow-missing-formatter = false;
  };
  programs = {
    alejandra = {
      enable = true;
      includes = ["flake.nix" "nix**/*.nix" "Notarin**/*.nix"];
    };
    rustfmt = {
      enable = true;
      includes = ["Notarin**/*.rs"];
    };
    toml-sort = {
      enable = true;
      includes = ["Notarin**/*.toml"];
    };
    shellcheck = {
      enable = true;
      includes = [
        "nix/*.sh"
        ".envrc"
        ".githooks/**"
      ];
    };
    mdformat = {
      enable = true;
      includes = [
        "README.md"
        "Notarin**/*.md"
      ];
    };
  };
}
