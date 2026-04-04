{ inputs, ... }:

let
  overlays = {

    firefox-addons = inputs.firefox-addons.overlays.default;

    # --------------------------------------

    #TODO:
    #custom-packages =
    #  final: prev:
    #  (prev.lib.packagesFromDirectoryRecursive {
    #    callPackage = prev.lib.callPackageWith final;
    #    directory = ../pkgs;
    #  });

    unstable-packages = final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
        overlays = [ ];
      };
    };

  };

  lib = inputs.nixpkgs.lib;
in
{
  # Custom modifications/overrides to upstream packages
  flake.overlays.default =
    final: prev:
    lib.attrNames overlays
    |> map (name: (overlays.${name} final prev)) # nixfmt hack
    |> lib.mergeAttrsList;
}

# References:
# - https://github.com/EmergentMind/nix-config/blob/dev/overlays/default.nix
