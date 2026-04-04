{

  perSystem =
    { pkgs, ... }:
    {
      # Nix formatter available through "nix fmt"
      # https://nix.dev/manual/nix/stable/command-ref/new-cli/nix3-fmt#example
      formatter = pkgs.nixfmt-tree;
    };

}
