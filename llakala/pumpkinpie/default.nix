{pkgs}: let
  inherit (pkgs) python3Packages;
  pyproject = builtins.fromTOML (builtins.readFile ./pyproject.toml);
in
  python3Packages.buildPythonApplication {
    src = ./.;
    pname = pyproject.project.name;
    inherit (pyproject.project) version;
    pyproject = true;
    build-system = with python3Packages; [setuptools];

    meta = {
      inherit (pyproject.project) description;
      mainProgram = pyproject.project.name;
    };
  }
