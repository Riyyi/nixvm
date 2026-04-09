{
  flake.nixosModules.keyring =
    { pkgs, ... }:
    {

      environment.systemPackages = with pkgs; [
        libsecret
      ];

      programs.seahorse.enable = true;

      services = {
        dbus.packages = with pkgs; [
          gnome-keyring
          gcr
        ];

        gnome.gnome-keyring.enable = true;
      };

      security.pam.services = {
        ly.enableGnomeKeyring = true;
      };

    };
}
