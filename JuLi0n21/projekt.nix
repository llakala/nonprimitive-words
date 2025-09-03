{
  pkgs,
  system,
  ...
}: {
  packages.${system} = {
    julion21 = pkgs.buildGoModule {
      pname = "julion21";
      version = "1.0.0";
      src = ./JuLi0n21;
    };
  };
}
