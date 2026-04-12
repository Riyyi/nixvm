{
  dot,
  inputs,
  self,
  ...
}:
let
  noctalia-colors = ".config/mango/noctalia.conf";
in
{
  flake.nixosModules.mangowc =
    {
      config,
      pkgs,
      ...
    }:
    let
      mangowc = self.packages.${pkgs.stdenv.hostPlatform.system}.mangowc;

      home = config.preferences.user.home;
      dotfiles = config.preferences.path.dotfiles;

      subDir = dot.subDir __curPos;
    in
    {
      programs.xwayland.enable = true;

      programs.mangowc = {
        enable = true;
        package = mangowc;
      };

      services.displayManager.sessionPackages = [ mangowc ];

      systemd.packages = [ mangowc ];

      xdg.portal = {
        enable = true;
        configPackages = [ mangowc ];
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
        ];
        wlr.enable = true;
      };

      # noctalia.conf wont be linked from Nix store, so it remains writable
      system.activationScripts.mango = ''
        ln -sf "${dotfiles}/${subDir}/dotfiles/${noctalia-colors}" \
               "${home}/${noctalia-colors}"
      '';
    };

  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    let
      mod = "SUPER";

      noctalia = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell;
      ghostty = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.ghostty;
    in
    {
      packages.mangowc = inputs.wrapper-modules.wrappers.mangowc.wrap {
        inherit pkgs;

        package = pkgs.mangowc.override { enableXWayland = true; };

        # Point .desktop to the wrapped application
        filesToPatch = [ "share/wayland-sessions/*.desktop" ];

        configFile.content = ''

          exec-once = ${noctalia}

          cursor_theme = capitaine-cursors-white
          cursor_size = 24

          # ----------------------------
          # Environment variables

          # HACK: 3D accel is broken on mango
          env = LIBGL_ALWAYS_SOFTWARE,1
          env = WLR_RENDERER,pixman
          env = WLR_NO_HARDWARE_CURSORS,1

          # ----------------------------
          # Look and feel

          borderpx = 2
          gappih = 8
          gappiv = 8
          gappoh = 10
          gappov = 10

          source-optional = ~/${noctalia-colors}

          # Master-stack layout
          new_is_master = 0
          smartgaps = 1
          default_mfact = 0.55
          default_nmaster = 1
          no_border_when_single = 1

          # Window switch overview
          ov_tab_mode = 1

          # Drag tiles with mouse
          drag_tile_to_tile = 1

          # ----------------------------
          # Input

          xkb_rules_layout = us

          # ----------------------------
          # Keybinds

          #--- General ---#

          # Terminal
          bind = ${mod}, Return, spawn, ${ghostty}

          # App launcher
          bind = ${mod}, D, spawn, ${noctalia} ipc call launcher toggle

          # Lock screen
          bind = ${mod}, C, spawn, ${noctalia} ipc call lockScreen lock

          #--- Control ---#

          # Close mango
          bind = ${mod}+SHIFT, M, quit

          #--- Window ---#

          bind = ${mod}, Q, killclient

          #-- State/flags --#

          # Toggle fullscreen mode
          bind = ${mod}, F, togglefullscreen

          # Toggle tiled/floating
          bind = ${mod}, Space, togglefloating

          #-- Focus --#

          # Focus window in direction
          bind = ${mod}, H, focusdir, left
          bind = ${mod}, L, focusdir, right
          bind = ${mod}, K, focusdir, up
          bind = ${mod}, J, focusdir, down
          bind = ${mod}, Left, focusdir, left
          bind = ${mod}, Right, focusdir, right
          bind = ${mod}, Up, focusdir, up
          bind = ${mod}, Down, focusdir, down

          # Focus previous/next window
          bind = ${mod}, Tab, toggleoverview
          bind = ${mod}+SHIFT, Tab, toggleoverview

          # Focus tag
          bind = ${mod}, 1, view, 1
          bind = ${mod}, 2, view, 2
          bind = ${mod}, 3, view, 3
          bind = ${mod}, 4, view, 4
          bind = ${mod}, 5, view, 5
          bind = ${mod}, 6, view, 6
          bind = ${mod}, 7, view, 7
          bind = ${mod}, 8, view, 8
          bind = ${mod}, 9, view, 9

          # Focus previous/next tag
          bind = ${mod}, minus, viewtoleft
          bind = ${mod}, equal, viewtoright

          # Focus last workspace
          bind = ${mod}, grave, view, -1

          # Focus previous/next monitor
          bind = ${mod}, bracketleft, focusmon, left
          bind = ${mod}, bracketright, focusmon, right

          # Special workspace (scratchpad)
          bind = ${mod}, T, toggle_scratchpad

          #-- Move --#

          # Move window in direction
          bind = ${mod}+SHIFT, H,     exchange_client, left
          bind = ${mod}+SHIFT, L,     exchange_client, right
          bind = ${mod}+SHIFT, K,     exchange_client, up
          bind = ${mod}+SHIFT, J,     exchange_client, down
          bind = ${mod}+SHIFT, Left,  exchange_client, left
          bind = ${mod}+SHIFT, Right, exchange_client, right
          bind = ${mod}+SHIFT, Up,    exchange_client, up
          bind = ${mod}+SHIFT, Down,  exchange_client, down

          # Send window to tag
          bind = ${mod}+SHIFT, 1, tagsilent, 1
          bind = ${mod}+SHIFT, 2, tagsilent, 2
          bind = ${mod}+SHIFT, 3, tagsilent, 3
          bind = ${mod}+SHIFT, 4, tagsilent, 4
          bind = ${mod}+SHIFT, 5, tagsilent, 5
          bind = ${mod}+SHIFT, 6, tagsilent, 6
          bind = ${mod}+SHIFT, 7, tagsilent, 7
          bind = ${mod}+SHIFT, 8, tagsilent, 8
          bind = ${mod}+SHIFT, 9, tagsilent, 9

          # Move window to previous/next workspace
          bind = ${mod}+SHIFT, minus, tagtoleft
          bind = ${mod}+SHIFT, equal, tagtoright

          # Move window to previous/next monitor
          bind = ${mod}+SHIFT, bracketleft, tagmon, left
          bind = ${mod}+SHIFT, bracketright, tagmon, right

          # Move floating window
          bind = CTRL+ALT, H,     smartmovewin, left
          bind = CTRL+ALT, L,     smartmovewin, right
          bind = CTRL+ALT, K,     smartmovewin, up
          bind = CTRL+ALT, J,     smartmovewin, down
          bind = CTRL+ALT, Left,  smartmovewin, left
          bind = CTRL+ALT, Right, smartmovewin, right
          bind = CTRL+ALT, Up,    smartmovewin, up
          bind = CTRL+ALT, Down,  smartmovewin, down

          # Swap window with master window
          bind = ${mod}+ALT, F, zoom

          # Special workspace (scratchpad)
          bind = ${mod}+SHIFT, T, minimized
          bind = ${mod}+SHIFT, U, restore_minimized

          #-- Resize --#

          # Resize windows
          bind = ${mod}+ALT, H,     resizewin, -10,  +0
          bind = ${mod}+ALT, L,     resizewin,  +0, +10
          bind = ${mod}+ALT, K,     resizewin,  +0, -10
          bind = ${mod}+ALT, J,     resizewin, +10,  +0
          bind = ${mod}+ALT, Left,  resizewin, -10,  +0
          bind = ${mod}+ALT, Right, resizewin,  +0, +10
          bind = ${mod}+ALT, Up,    resizewin,  +0, -10
          bind = ${mod}+ALT, Down,  resizewin, +10,  +0

          # Move/resize windows with mainMod + LMB/RMB and dragging
          mousebind = ${mod}, btn_left, moveresize, curmove
          mousebind = ${mod}, btn_right, moveresize, cursize

          # ----------------------------
          # Windows and tags

          # Set to floating
          windowrule = isfloating:1, appid:imv
          windowrule = isfloating:1, appid:mpv
          windowrule = isfloating:1, appid:firefox, title:Library
          windowrule = isfloating:1, appid:firefox, title:^About.*
          windowrule = isfloating:1, appid:thunar, title:File Operation Progress
          windowrule = isfloating:1, appid:thunar, title:Rename ".*"

          tagrule = id:1, layout_name:tile
          tagrule = id:2, layout_name:tile
          tagrule = id:3, layout_name:tile
          tagrule = id:4, layout_name:tile
          tagrule = id:5, layout_name:tile
          tagrule = id:6, layout_name:tile
          tagrule = id:7, layout_name:tile
          tagrule = id:8, layout_name:tile
          tagrule = id:9, layout_name:tile

        '';
      };
    };
}
