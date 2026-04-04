{ inputs, ... }:
{
  flake.nixosModules.hjem =
    { config, ... }:
    let
      user = config.preferences.user.name;
      home = config.preferences.user.home;
    in
    {
      imports = [
        inputs.hjem.nixosModules.default
      ];

      config = {
        hjem = {
          users."${user}" = {
            enable = true;
            directory = home;
            user = user;
          };

          clobberByDefault = true; # overwrite existing files
        };
      };
    };
}
