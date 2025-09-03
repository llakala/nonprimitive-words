{
  pkgs,
  system,
  ...
}:

{
  packages.${system} = {
    pumpkinpie = pkgs.writers.writePyPy3Bin "pumpkinpie"
      { flakeIgnore = [ "E203" ]; }
      (builtins.readFile ./pumpkin/main.py);

    pineapplepie = pkgs.writers.writePyPy3Bin "pineapplepie"
      { flakeIgnore = [ "E722" ]; }
      (builtins.readFile ./pineapple/main.py);
  };
}
