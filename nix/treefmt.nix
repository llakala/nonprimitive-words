_: {
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
      ];
    };
  };
}
