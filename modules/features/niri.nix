{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }:
  let
    niri = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
  in
  {
    programs.niri = {
      enable = true;
      package = niri;
    };

    services = {
      displayManager.sessionPackages = [ niri ];
      gnome.gnome-keyring.enable = true;
    };

    systemd.packages = [ niri ];

    xdg.portal = {
      enable = true;
      configPackages = [ niri ];
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };
  };

  perSystem = { pkgs, lib, self', ... }:
  let
    noctalia = lib.getExe self'.packages.noctalia-shell;
  in
  {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        spawn-at-startup = [
          noctalia
        ];

	prefer-no-csd = null;

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        layout.gaps = 16;

        input = {
	  focus-follows-mouse = null;
          keyboard.xkb.layout = "us";
	};

        binds = {
          "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;
          "Mod+Q".close-window = null;
          "Mod+D".spawn-sh = "${noctalia} ipc call launcher toggle";

          "Mod+F".maximize-column = null;
          "Mod+G".fullscreen-window = null;
          "Mod+Space".toggle-window-floating = null;
        };

	debug.honor-xdg-activation-with-invalid-serial = null; # recommended by Noctalia
      };
    };
  };
}
