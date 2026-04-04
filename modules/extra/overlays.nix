{
  inputs,
  ...
}:

{
  flake = {

    # Custom modifications/overrides to upstream packages
    #overlays = import ../../overlays { inherit inputs; }; # TODO:

  };
}
