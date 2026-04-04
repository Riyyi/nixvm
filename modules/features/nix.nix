{ outputs, ... }:
{
  flake.nixosModules.nix =
    { lib, ... }:
    {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      nixpkgs = {
        config.allowUnfree = true;

        overlays = lib.mkAfter [
          outputs.overlays.default
        ];
      };
    };
}
