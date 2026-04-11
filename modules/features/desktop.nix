{ self, ... }:
{
  flake.nixosModules.desktop =
    { pkgs, ... }:
    {

      imports = [
        self.nixosModules.greeter
        self.nixosModules.keyring
        self.nixosModules.theme

        self.nixosModules.firefox
        self.nixosModules.ghostty
        self.nixosModules.hyprland
        self.nixosModules.niri
        self.nixosModules.noctalia
        self.nixosModules.vscode
      ];

      environment.systemPackages = with pkgs; [
        gedit
        gvfs
        imv
        kdePackages.kolourpaint
        mpv
        opencode
        wev
        thunar
        thunar-volman
      ];

    };
}
