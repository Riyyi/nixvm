{
  flake.nixosModules.base =
    { config, lib, ... }:
    {
      options.preferences = {
        path.dotfiles = lib.mkOption {
          type = lib.types.str;
          default = "${config.preferences.user.home}/nixvm";
          description = "Path where this repo is cloned to.";
        };
      };
    };
}
