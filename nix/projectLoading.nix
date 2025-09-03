{
  lib,
  system,
  utils,
  ...
} @ specialArgs: let
  dirs =
    builtins.attrNames
    (lib.attrsets.filterAttrs (_: v: v == "directory") (builtins.readDir utils.flakePath));
  projectDirs = builtins.filter (dir: builtins.pathExists (utils.flakePath + "/${dir}/project.nix")) dirs;
  # The following function is for processing the project.nix files into a usable format
  # Several formats were supported for QOL and freedom of choice.
  callProjectExpression = dir: let
    project = import "${utils.flakePath}/${dir}/project.nix";
    type = builtins.typeOf project;
    processProjectExpression =
      # Derivations are technically sets, but they provide an attr identifying them as derivations
      if project ? type # Just checking for the attrs existence should be enough
      then {packages.${system}.${dir} = project;}
      # If it's a set, then we'll treat it akin to a module
      else if type == "set"
      then project
      # If it's a function, it's a bit more complicated.
      # We will call it, then recurseFunction handles calling it again if needed
      else if type == "lambda"
      then recurseFunction project
      else
        throw ''
          project.nix in ${dir} must be one of the following types:
          - An attribute set, ideally in the flake output schema
          - A plain derivation, which will be QOL wrapped into a flake output schema
          - Or a function, that when called will return any of the above types
          ${
            ""
            /*
            Technically, the function can also yield a function and be valid.
            That is, if recursively called, it will eventually yield another valid type.
            */
          }
          However, the type found was: ${type}
        '';
  in
    processProjectExpression;
  recurseFunction = function: let
    functionResult = function specialArgs;
    functionType = builtins.typeOf functionResult;
  in
    if functionType == "lambda"
    then recurseFunction functionResult
    else functionResult;
  projectsEvaluated = builtins.map callProjectExpression projectDirs;
  mergedProjects = utils.recursiveMerge projectsEvaluated;
in
  mergedProjects
