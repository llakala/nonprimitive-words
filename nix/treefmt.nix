{...}: {
  projectRootFile = ".git/config";
  settings = {
    allow-missing-formatter = false;
  };
  programs = {
    alejandra.enable = true;
    ruff-format.enable = true;
    asmfmt.enable = true;
  };
}
