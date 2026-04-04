{
  description = "NixOS configuration";

  nixConfig = {
    extra-experimental-features = [ "pipe-operators" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hjem.url = "github:feel-co/hjem";
    hjem.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    #import-tree.url = "github:vic/import-tree";

    wrappers.url = "github:Lassulus/wrappers";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
  };
  
  outputs = inputs:
    let
      inherit (inputs.nixpkgs) lib;
      import-tree =
        path:
        path
        |> lib.fileset.fileFilter (file: file.hasExt "nix" && !(lib.hasPrefix "_" file.name))
        |> lib.fileset.toList;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = import-tree ./modules;

      _module.args.rootPath = ./.;
    };
}
