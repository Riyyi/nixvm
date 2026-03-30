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

environment = {
  #QT_QPA_PLATFORMTHEME = "qt6ct";
};

        prefer-no-csd = null;

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        layout.gaps = 16;

        input = {
          warp-mouse-to-focus = null;
          focus-follows-mouse = null;
          keyboard.xkb.layout = "us";
        };

        binds = {
          ##--- General ---##


          # Terminal
          "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;

          # App launcher
          "Mod+D".spawn-sh = "${noctalia} ipc call launcher toggle";

          # Lock screen
          "Mod+C".spawn-sh = "${noctalia} ipc call lockScreen lock";


          ##--- Control ---##


          # Close niri
          "Mod+Shift+M".quit = null;

          # Show hotkeys
          "Mod+Shift+slash".show-hotkey-overlay= null;

          # Show overview
          "Mod+O".toggle-overview = null;

          # Printscreen
          "Print".screenshot = null;
          "Ctrl+Print".screenshot-screen = null;
          "Alt+Print".screenshot-window = null;


          ##--- Column ---##


          "Mod+Q".close-window = null;


          #-- State/flags --#

          # Maximize column
          "Mod+F".maximize-window-to-edges = null;

          # Toggle fullscreen mode
          "Mod+G".fullscreen-window = null;

          # Toggle tiled/floating
          "Mod+Space".toggle-window-floating = null;

          # Cycle between column width presets, 1/3, 1/2 and 2/3 of the output
          "Mod+R".switch-preset-column-width = null;

          # Toggle tabbed column mode
          "Mod+W".toggle-column-tabbed-display = null;

          #-- Focus --#

          # Focus window in direction
          "Mod+H".focus-column-left = null;
          "Mod+L".focus-column-right = null;
          "Mod+K".focus-window-up = null;
          "Mod+J".focus-window-down = null;
          "Mod+Left".focus-column-left = null;
          "Mod+Right".focus-column-right = null;
          "Mod+Up".focus-window-up = null;
          "Mod+Down".focus-window-down = null;

          # Focus previous/next column
          "Mod+WheelScrollUp".focus-column-left = null;
          "Mod+WheelScrollDown".focus-column-right = null;

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
          "Mod+minus".focus-workspace-up = null;
          "Mod+equal".focus-workspace-down = null;
          "Mod+Shift+WheelScrollUp".focus-workspace-up = null;
          "Mod+Shift+WheelScrollDown".focus-workspace-down = null;

          # Focus last workspace
          "Mod+grave".focus-workspace-previous = null;

          # Toggle focus floating/tiling
          "Mod+Shift+Space".switch-focus-between-floating-and-tiling = null;

          # Focus previous/next monitor
          "Mod+bracketleft".focus-monitor-left = null;
          "Mod+bracketright".focus-monitor-right = null;

          #-- Move --#

          # Move window in direction
          "Mod+Shift+H".move-column-left = null;
          "Mod+Shift+L".move-column-right = null;
          "Mod+Shift+K".move-window-up = null;
          "Mod+Shift+J".move-window-down = null;
          "Mod+Shift+Left".move-column-left = null;
          "Mod+Shift+Right".move-column-right = null;
          "Mod+Shift+Up".move-window-up = null;
          "Mod+Shift+Down".move-window-down = null;

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
          "Mod+Shift+minus".move-column-to-workspace-up = null;
          "Mod+Shift+equal".move-column-to-workspace-down = null;

          # Move column to previous/next monitor
          "Mod+Shift+bracketleft".move-column-to-monitor-left = null;
          "Mod+Shift+bracketright".move-column-to-monitor-right = null;

          # Move window in and out of a column
          "Mod+Shift+Alt+H".consume-or-expel-window-left = null;
          "Mod+Shift+Alt+L".consume-or-expel-window-right = null;
          "Mod+Shift+Alt+Left".consume-or-expel-window-left = null;
          "Mod+Shift+Alt+Right".consume-or-expel-window-right = null;

          # Move floating window
          #TODO

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
          "Mod+Alt+F".expand-column-to-available-width = null;

        };

        debug.honor-xdg-activation-with-invalid-serial = null; # recommended by Noctalia
      };
    };
  };
}

# Resources:
# - https://github.com/vimjoyer/nixconf/blob/main/modules/wrappedPrograms/niri.nix
# - https://github.com/niri-wm/niri/blob/main/resources/default-config.kdl
# - https://docs.noctalia.dev/getting-started/compositor-settings/niri/
