{
  pkgs,
  system,
  ...
}: {
  packages.${system} = {
    pumpkinpie = import ./pumpkinpie {inherit pkgs;};
  };
}
