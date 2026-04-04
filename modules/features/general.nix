{ self, ... }:
{
  flake.nixosModules.general =
    { config, pkgs, ... }:
    {
      imports = [
        self.nixosModules.hjem
      ];

      users.users.${config.preferences.user.name} = {
        isNormalUser = true;
        description = "${config.preferences.user.name}'s account";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = self.packages.${pkgs.stdenv.hostPlatform.system}.zsh;
      };
    };
}
