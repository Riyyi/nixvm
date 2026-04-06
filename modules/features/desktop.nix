{ self, ... }:
{
  flake.nixosModules.desktop =
    { pkgs, ... }:
    {

      imports = [
        self.nixosModules.greeter
        self.nixosModules.theme

        self.nixosModules.firefox
        self.nixosModules.ghostty
        self.nixosModules.niri
        self.nixosModules.noctalia
      ];

      environment.systemPackages = with pkgs; [
        gedit
        gnome-keyring
        imv
        kdePackages.kolourpaint
        mpv
        wev
        xfce.thunar
      ];

    };
}
