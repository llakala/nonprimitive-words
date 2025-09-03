{
  pkgs,
  system,
  ...
}: let
  python3Packages = pkgs.python3Packages;
in {
  packages.${system} = let
    pyproject = builtins.fromTOML (builtins.readFile ./pyproject.toml);
  in {
    ${pyproject.project.name} = (
      python3Packages.buildPythonApplication {
        src = ./.;
        pname = pyproject.project.name;
        version = pyproject.project.version;
        pyproject = true;
        build-system = with python3Packages; [setuptools];

        meta = {
          description = pyproject.project.description;
          mainProgram = pyproject.project.name;
        };
      }
    );
  };
}
