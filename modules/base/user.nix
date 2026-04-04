{
  flake.nixosModules.base = { config, lib, ... }: {
    options.preferences = {
      user.name = lib.mkOption {
        type = lib.types.str;
        default = "rick";
      };

      user.home = lib.mkOption {
        type = lib.types.str;
        default = "/home/${config.preferences.user.name}";
      };
    };
  };
}
