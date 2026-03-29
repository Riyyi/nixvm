{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }:
  let
    myNiri = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
  in
  {
    programs.niri = {
      enable = true;
      package = myNiri;
    };

    services = {
      displayManager.sessionPackages = [ myNiri ];
      gnome.gnome-keyring.enable = true;
    };

    systemd.packages = [ myNiri ];

    xdg.portal = {
      enable = true;
      configPackages = [ myNiri ];
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        spawn-at-startup = [
          (lib.getExe self'.packages.myNoctalia)
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input.keyboard.xkb.layout = "us";

        layout.gaps = 5;

        binds = {
          "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;
          "Mod+Q".close-window = null;
          "Mod+D".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
        };

	extraConfig = ''
          debug {
	    honor-xdg-activation-with-invalid-serial
	  }
	'';
      };
    };
  };
}
