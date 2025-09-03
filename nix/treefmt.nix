_: {
  projectRootFile = ".git/config";
  settings = {
    allow-missing-formatter = false;
  };
  programs = {
    alejandra.enable = true;
    rustfmt = {
      enable = true;
      includes = ["Notarin/**/*.rs"];
    };
    toml-sort = {
      enable = true;
      includes = ["Notarin/**/*.toml"];
    };
  };
}
