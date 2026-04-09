{ self, inputs, ... }:
{
  flake.nixosModules.niri =
    {
      config,
      pkgs,
      ...
    }:
    let
      niri = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    in
    {
      programs.niri = {
        enable = true;
        package = niri;
      };

      services.displayManager.sessionPackages = [ niri ];

      systemd.packages = [ niri ];

      xdg.portal = {
        enable = true;
        configPackages = [ niri ];
        extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      };
    };

  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    let
      noctalia = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell;
      ghostty = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.ghostty;
    in
    {
      packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;

        # Point .desktop to the wrapped application
        filesToPatch = [ "share/wayland-sessions/*.desktop" ];

        v2-settings = true;

        settings = {

          # Apply theme set in noctalia, cant work with live updating unfortunately
          include = [ ./noctalia.kdl ];

          spawn-at-startup = [
            noctalia
          ];

          # NOTE: Cursor settings are duplicated here and in theme.nix
          cursor = {
            xcursor-theme = "capitaine-cursors-white";
            xcursor-size = 24;
          };

          prefer-no-csd = _: { };

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          layout.gaps = 16;

          input = {
            warp-mouse-to-focus = _: { };
            focus-follows-mouse = _: { };
            keyboard.xkb.layout = "us";
          };

          binds = {
            ##--- General ---##

            # Terminal
            "Mod+Return".spawn-sh = ghostty;

            # App launcher
            "Mod+D".spawn-sh = "${noctalia} ipc call launcher toggle";

            # Lock screen
            "Mod+C".spawn-sh = "${noctalia} ipc call lockScreen lock";

            ##--- Control ---##

            # Close niri
            "Mod+Shift+M".quit = _: { };

            # Show hotkeys
            "Mod+Shift+slash".show-hotkey-overlay = _: { };

            # Show overview
            "Mod+O".toggle-overview = _: { };

            # Printscreen
            "Print".screenshot = _: { };
            "Ctrl+Print".screenshot-screen = _: { };
            "Alt+Print".screenshot-window = _: { };

            ##--- Column ---##

            "Mod+Q".close-window = _: { };

            #-- State/flags --#

            # Maximize column
            "Mod+F".maximize-window-to-edges = _: { };

            # Toggle fullscreen mode
            "Mod+G".fullscreen-window = _: { };

            # Toggle tiled/floating
            "Mod+Space".toggle-window-floating = _: { };

            # Cycle between column width presets, 1/3, 1/2 and 2/3 of the output
            "Mod+R".switch-preset-column-width = _: { };

            # Toggle tabbed column mode
            "Mod+W".toggle-column-tabbed-display = _: { };

            #-- Focus --#

            # Focus window in direction
            "Mod+H".focus-column-left = _: { };
            "Mod+L".focus-column-right = _: { };
            "Mod+K".focus-window-up = _: { };
            "Mod+J".focus-window-down = _: { };
            "Mod+Left".focus-column-left = _: { };
            "Mod+Right".focus-column-right = _: { };
            "Mod+Up".focus-window-up = _: { };
            "Mod+Down".focus-window-down = _: { };

            # Focus previous/next column
            "Mod+WheelScrollUp".focus-column-left = _: { };
            "Mod+WheelScrollDown".focus-column-right = _: { };

            # Focus workspace
            "Mod+1".focus-workspace = 1;
            "Mod+2".focus-workspace = 2;
            "Mod+3".focus-workspace = 3;
            "Mod+4".focus-workspace = 4;
            "Mod+5".focus-workspace = 5;
            "Mod+6".focus-workspace = 6;
            "Mod+7".focus-workspace = 7;
            "Mod+8".focus-workspace = 8;
            "Mod+9".focus-workspace = 9;
            "Mod+0".focus-workspace = 10;

            # Focus previous/next workspace
            "Mod+minus".focus-workspace-up = _: { };
            "Mod+equal".focus-workspace-down = _: { };
            "Mod+Shift+WheelScrollUp".focus-workspace-up = _: { };
            "Mod+Shift+WheelScrollDown".focus-workspace-down = _: { };

            # Focus last workspace
            "Mod+grave".focus-workspace-previous = _: { };

            # Toggle focus floating/tiling
            "Mod+Shift+Space".switch-focus-between-floating-and-tiling = _: { };

            # Focus previous/next monitor
            "Mod+bracketleft".focus-monitor-left = _: { };
            "Mod+bracketright".focus-monitor-right = _: { };

            #-- Move --#

            # Move window in direction
            "Mod+Shift+H".move-column-left = _: { };
            "Mod+Shift+L".move-column-right = _: { };
            "Mod+Shift+K".move-window-up = _: { };
            "Mod+Shift+J".move-window-down = _: { };
            "Mod+Shift+Left".move-column-left = _: { };
            "Mod+Shift+Right".move-column-right = _: { };
            "Mod+Shift+Up".move-window-up = _: { };
            "Mod+Shift+Down".move-window-down = _: { };

            # Send column to workspace
            "Mod+Shift+1".move-column-to-workspace = 1;
            "Mod+Shift+2".move-column-to-workspace = 2;
            "Mod+Shift+3".move-column-to-workspace = 3;
            "Mod+Shift+4".move-column-to-workspace = 4;
            "Mod+Shift+5".move-column-to-workspace = 5;
            "Mod+Shift+6".move-column-to-workspace = 6;
            "Mod+Shift+7".move-column-to-workspace = 7;
            "Mod+Shift+8".move-column-to-workspace = 8;
            "Mod+Shift+9".move-column-to-workspace = 9;
            "Mod+Shift+0".move-column-to-workspace = 10;

            # Move column to previous/next workspace
            "Mod+Shift+minus".move-column-to-workspace-up = _: { };
            "Mod+Shift+equal".move-column-to-workspace-down = _: { };

            # Move column to previous/next monitor
            "Mod+Shift+bracketleft".move-column-to-monitor-left = _: { };
            "Mod+Shift+bracketright".move-column-to-monitor-right = _: { };

            # Move window in and out of a column
            "Mod+Shift+Alt+H".consume-or-expel-window-left = _: { };
            "Mod+Shift+Alt+L".consume-or-expel-window-right = _: { };
            "Mod+Shift+Alt+Left".consume-or-expel-window-left = _: { };
            "Mod+Shift+Alt+Right".consume-or-expel-window-right = _: { };

            # Move floating window
            # TODO:

            #-- Resize --#

            # Resize windows
            "Mod+Alt+H".set-column-width = "-5%";
            "Mod+Alt+L".set-column-width = "+5%";
            "Mod+Alt+K".set-window-height = "+5%";
            "Mod+Alt+J".set-window-height = "-5%";
            "Mod+Alt+Left".set-column-width = "-5%";
            "Mod+Alt+Right".set-column-width = "+5%";
            "Mod+Alt+Up".set-window-height = "+5%";
            "Mod+Alt+Down".set-window-height = "-5%";

            # Resize window to take up the available width
            "Mod+Alt+F".expand-column-to-available-width = _: { };

          };

          debug.honor-xdg-activation-with-invalid-serial = _: { }; # recommended by Noctalia
        };
      };
    };
}

# Resources:
# - https://github.com/vimjoyer/nixconf/blob/main/modules/wrappedPrograms/niri.nix
# - https://github.com/niri-wm/niri/blob/main/resources/default-config.kdl
# - https://docs.noctalia.dev/getting-started/compositor-settings/niri/
# - https://niri-wm.github.io/niri/Configuration%3A-Miscellaneous.html#cursor
