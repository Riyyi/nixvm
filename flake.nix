{
  description = "NixOS configuration";

  nixConfig = {
    extra-experimental-features = [ "pipe-operators" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    flake-parts.url = "github:hercules-ci/flake-parts";

    wrappers.url = "github:Lassulus/wrappers";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    hjem.url = "github:feel-co/hjem";
    hjem.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      import-tree =
        path:
        path
        |> lib.fileset.fileFilter (file: file.hasExt "nix" && !(lib.hasPrefix "_" file.name))
        |> lib.fileset.toList;

      inherit (inputs.self) outputs;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = import-tree ./modules;

      _module.args.outputs = outputs;
      _module.args.rootPath = ./.;
    };
}
