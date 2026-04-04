{
  inputs,
  outputs,
  ...
}:

{

  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        # TODO: Test if this actually applies overlays inside flake-part modules
        overlays = [ outputs.overlays.default ];
      };
    in
    {
      _module.args.pkgs = pkgs; # initialize pkgs with overlays
    };

}
