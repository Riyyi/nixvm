{ self, ... }:
{
  # Module for generic stuff that every host needs

  flake.nixosModules.general =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      imports = [
        self.nixosModules.hjem
        self.nixosModules.nix

        self.nixosModules.environment
      ];

      users.users.${config.preferences.user.name} = {
        isNormalUser = true;
        description = "${config.preferences.user.name}";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = lib.getExe selfpkgs.environment;
      };
    };
}
