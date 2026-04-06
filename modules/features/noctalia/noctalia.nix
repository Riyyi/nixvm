{ inputs, ... }:
{

  flake.nixosModules.noctalia =
    { config, ... }:
    let
      user = config.preferences.user.name;

      modDir = dirOf __curPos.file;
      entries = builtins.readDir "${modDir}/Pictures/Wallpapers";
      files = builtins.filter (name: entries.${name} == "regular") (builtins.attrNames entries);
    in
    {

      # Deploy wallpapers from repo to home directory
      hjem.users.${user} = {
        files = builtins.listToAttrs (
          map (file: {
            name = "Pictures/Wallpapers/${file}";
            value = {
              source = ./Pictures/Wallpapers + "/${file}";
            };
          }) files
        );
      };

    };

  perSystem =
    { pkgs, ... }:
    {
      packages.noctalia-shell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;

        settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
      };
    };
}
