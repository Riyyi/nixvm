{
  dot,
  inputs,
  self,
  ...
}:
let
  noctalia-colors = ".config/hypr/noctalia/noctalia-colors.conf";
in
{
  flake.nixosModules.hyprland =
    { config, pkgs, ... }:
    let
      hyprland = self.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

      home = config.preferences.user.home;
      dotfiles = config.preferences.path.dotfiles;

      subDir = dot.subDir __curPos;
    in
    {
      environment.systemPackages = with pkgs; [
        uwsm
        xwayland
      ];

      programs.hyprland = {
        enable = true;
        package = hyprland;
        withUWSM = true;
        xwayland.enable = true;
      };

      services.displayManager.sessionPackages = [ hyprland ];

      systemd.packages = [ hyprland ];

      xdg.portal = {
        enable = true;
        configPackages = [ hyprland ];
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };

      # noctalia-colors.conf wont be linked from Nix store, so it remains writable
      system.activationScripts.hyprland = ''
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
      packages.hyprland =
        (inputs.wrappers.wrapperModules.hyprland.apply {
          inherit pkgs;

          # Point .desktop to the wrapped application
          filesToPatch = [ "share/wayland-sessions/*.desktop" ];

          "hypr.conf".content =
            dot.toHyprconf {
              attrs = {

                monitor = [
                  ", preferred, auto, 1"
                ];

                exec-once = [
                  noctalia
                ];

                # ----------------------------
                # Environment variables

                env = [
                  "XDG_CURRENT_DESKTOP,Hyprland"
                  "XDG_SESSION_TYPE,wayland"
                  "XDG_SESSION_DESKTOP,Hyprland"

                  "XCURSOR_SIZE,24"
                  "HYPRCURSOR_SIZE,24"

                  "LIBGL_ALWAYS_SOFTWARE,1" # HACK: 3d accell is broken on Hyprland
                  "WLR_RENDERER,pixman"

                ];

                # ----------------------------
                # Look and feel

                general = {
                  gaps_in = 5;
                  gaps_out = 10;

                  border_size = 2;

                  resize_on_border = false;

                  allow_tearing = false;

                  layout = "dwindle";
                };

                decoration = {
                  rounding = 0;

                  active_opacity = 1.0;
                  inactive_opacity = 1.0;

                  shadow.enabled = false;
                  blur.enabled = false;
                };

                source = [
                  "~/${noctalia-colors}"
                ];

                animations = {
                  enabled = true;

                  # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

                  bezier = [
                    "easeOutQuint,0.23,1,0.32,1"
                    "easeInOutCubic,0.65,0.05,0.36,1"
                    "linear,0,0,1,1"
                    "almostLinear,0.5,0.5,0.75,1.0"
                    "quick,0.15,0,0.1,1"
                  ];
                };

                # Ref https://wiki.hyprland.org/Configuring/Workspace-Rules/
                # "Smart gaps" / "No gaps when only"
                workspace = [
                  "w[tv1], gapsout:0, gapsin:0"
                  "f[1], gapsout:0, gapsin:0"
                ];
                windowrule = [
                  "border_size 0, match:float 0, match:workspace w[tv1]"
                  "rounding 0, match:float 0, match:workspace w[tv1]"
                  "border_size 0, match:float 0, match:workspace f[1]"
                  "rounding 0, match:float 0, match:workspace f[1]"
                ];

                # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
                dwindle = {
                  force_split = 2; # split to the bottom right
                  preserve_split = true;
                  pseudotile = false;
                };

                # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
                master = {
                  new_status = "master";
                };

                # https://wiki.hyprland.org/Configuring/Variables/#misc
                misc = {
                  disable_hyprland_logo = true;
                  vfr = true; # lower amount of sent frames when nothing is happening on-screen
                };

                # ----------------------------
                # Input

                input = {
                  kb_layout = "us";
                  kb_variant = "";
                  kb_model = "";
                  kb_rules = "";

                  follow_mouse = 1;

                  sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

                  touchpad = {
                    natural_scroll = false;
                  };
                };

                # https://wiki.hyprland.org/Configuring/Variables/#gestures
                gestures = {
                  workspace_swipe_touch = false;
                };

                # ----------------------------
                # Keybindings

                bind = [
                  # --- Control ---#

                  # Close Hyprland
                  "${mod} SHIFT, M, exit,"

                  # --- Window ---#

                  # Close window
                  "${mod}, q, killactive,"

                  #-- State/flags --#

                  # Toggle fullscreen mode
                  "${mod}, f, fullscreen"

                  # Toggle tiled/floating
                  "${mod}, Space, togglefloating,"

                  #-- Focus --#

                  # Focus window in direction
                  "${mod}, h, movefocus, l"
                  "${mod}, j, movefocus, d"
                  "${mod}, k, movefocus, u"
                  "${mod}, l, movefocus, r"
                  "${mod}, left, movefocus, l"
                  "${mod}, right, movefocus, r"
                  "${mod}, up, movefocus, u"
                  "${mod}, down, movefocus, d"

                  # Focus previous/next window"
                  "${mod}, Tab, cyclenext"
                  "${mod} SHIFT, Tab, cyclenext, prev"

                  # Focus workspace"
                  "${mod}, 1, workspace, 1"
                  "${mod}, 2, workspace, 2"
                  "${mod}, 3, workspace, 3"
                  "${mod}, 4, workspace, 4"
                  "${mod}, 5, workspace, 5"
                  "${mod}, 6, workspace, 6"
                  "${mod}, 7, workspace, 7"
                  "${mod}, 8, workspace, 8"
                  "${mod}, 9, workspace, 9"
                  "${mod}, 0, workspace, 10"

                  # Focus previous/next workspace
                  "${mod}, equal, workspace, e+1"
                  "${mod}, minus, workspace, e-1"

                  # Focus last workspace"
                  "${mod}, GRAVE, focuscurrentorlast"

                  # Focus previous/next monitor"
                  # TODO"

                  # Special workspace (scratchpad)"
                  "${mod}, T, togglespecialworkspace, magic"

                  #-- Move --#

                  # Send window to workspace"
                  "${mod} SHIFT, 1, movetoworkspacesilent, 1"
                  "${mod} SHIFT, 2, movetoworkspacesilent, 2"
                  "${mod} SHIFT, 3, movetoworkspacesilent, 3"
                  "${mod} SHIFT, 4, movetoworkspacesilent, 4"
                  "${mod} SHIFT, 5, movetoworkspacesilent, 5"
                  "${mod} SHIFT, 6, movetoworkspacesilent, 6"
                  "${mod} SHIFT, 7, movetoworkspacesilent, 7"
                  "${mod} SHIFT, 8, movetoworkspacesilent, 8"
                  "${mod} SHIFT, 9, movetoworkspacesilent, 9"
                  "${mod} SHIFT, 0, movetoworkspacesilent, 10"

                  # Move window to previous/next workspace"
                  "${mod} SHIFT, equal, movetoworkspace, e+1"
                  "${mod} SHIFT, minus, movetoworkspace, e-1"

                  # Move window to previous/next monitor"
                  # TODO"

                  # Move floating window"
                  "Control_L Alt_L, h, moveactive, -30 0"
                  "Control_L Alt_L, j, moveactive, 0 30"
                  "Control_L Alt_L, k, moveactive, 0 -30"
                  "Control_L Alt_L, l, moveactive, 30 0"
                  "Control_L Alt_L, left, moveactive, -30 0"
                  "Control_L Alt_L, right, moveactive, 30 0"
                  "Control_L Alt_L, up, moveactive, 0 -30"
                  "Control_L Alt_L, down, moveactive, 0 30"

                  # Flip the tree from the current windows parent"
                  "${mod} Alt_L, 5, swapsplit,   # dwindle"
                  "${mod} Alt_L, 6, togglesplit, # dwindle"

                  # Special workspace (scratchpad)"
                  "${mod} SHIFT, T, movetoworkspace, special:magic"

                  #-- Resize --#

                  # Resize windows
                  "${mod} Alt_L, h, resizeactive, -10 0"
                  "${mod} Alt_L, j, resizeactive, 0 10"
                  "${mod} Alt_L, k, resizeactive, 0 -10"
                  "${mod} Alt_L, l, resizeactive, 10 0"
                  "${mod} Alt_L, left, resizeactive, -10 0"
                  "${mod} Alt_L, right, resizeactive, 10 0"
                  "${mod} Alt_L, up, resizeactive, 0 -10"
                  "${mod} Alt_L, down, resizeactive, 0 10"

                  #-- Preselect node --#

                  "${mod} Control_L, h, layoutmsg, preselect left"
                  "${mod} Control_L, j, layoutmsg, preselect down"
                  "${mod} Control_L, k, layoutmsg, preselect up"
                  "${mod} Control_L, l, layoutmsg, preselect right"
                  "${mod} Control_L, left, layoutmsg, preselect left"
                  "${mod} Control_L, right, layoutmsg, preselect right"
                  "${mod} Control_L, up, layoutmsg, preselect up"
                  "${mod} Control_L, down, layoutmsg, preselect down"

                  # --- General --- #

                  # Start terminal
                  "${mod}, Return, exec, ${ghostty}"
                  "${mod}, t, exec, ${lib.getExe pkgs.kdePackages.konsole}"

                  # Start noctalia (program launcher)
                  "${mod}, d, exec, ${noctalia} ipc call launcher toggle"

                  # mpv"
                  "${mod},	   m, exec, play"
                  "${mod} SHIFT, m, exec, play queue"

                  #--- Control, compositor agnostic ---#

                  # Screen capture"
                  # ",		  Print, exec, printscreen"
                  # "Control_L, Print, exec, aliases screencast"

                ];

                bindm = [

                  # Move/resize windows with mainMod + LMB/RMB and dragging
                  "${mod}, mouse:272, movewindow"
                  "${mod}, mouse:273, resizewindow"

                ];
              };
            }
            + dot.toHyprconf {
              attrs = {

                # ----------------------------
                # Windows and workspaces

                windowrule = [

                  # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
                  # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

                  # Ignore maximize requests from apps. You'll probably like this.
                  "suppress_event maximize, match:class .*"

                  # Fix some dragging issues with XWayland
                  "no_focus true, match:class ^$, match:title ^$, match:xwayland true, match:float true, match:fullscreen false, match:pin false"

                  # Set to floating
                  "float true, match:class imv # window rule v1 can only do either class or title, not both"
                  "float true, match:class mpv"
                  "float true, match:class firefox, match:title Library"
                  "float true, match:class firefox, match:title ^About.*"
                  "float true, match:class thunar, match:title File Operation Progress"
                ];

                workspace = [
                  # Put workspaces on specific monitors
                  "1,  monitor:Virtual-1, persistent:true, default:true"
                  "2,  monitor:Virtual-1, persistent:true"
                  "3,  monitor:Virtual-1, persistent:true"
                  "4,  monitor:Virtual-1, persistent:true"
                  "5,  monitor:Virtual-1, persistent:true"
                  "6,  monitor:Virtual-1, persistent:true"
                  "7,  monitor:Virtual-1, persistent:true"
                  "8,  monitor:Virtual-1, persistent:true"
                  "9,  monitor:Virtual-2, persistent:true, default:true"
                  "10, monitor:Virtual-3, persistent:true, default:true"
                ];

                # NOTE: Hyprland config is read in order and nix sorts alphabetically,
                # so "bezier" would come after "animation", breaking the reference
                animations = {
                  animation = [
                    "global, 1, 10, default"
                    "border, 1, 5.39, easeOutQuint"
                    "windows, 1, 4.79, easeOutQuint"
                    "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
                    "windowsOut, 1, 1.49, linear, popin 87%"
                    "fadeIn, 1, 1.73, almostLinear"
                    "fadeOut, 1, 1.46, almostLinear"
                    "fade, 1, 3.03, quick"
                    "layers, 1, 3.81, easeOutQuint"
                    "layersIn, 1, 4, easeOutQuint, fade"
                    "layersOut, 1, 1.5, linear, fade"
                    "fadeLayersIn, 1, 1.79, almostLinear"
                    "fadeLayersOut, 1, 1.39, almostLinear"
                    "workspaces, 1, 1.94, almostLinear, fade"
                    "workspacesIn, 1, 1.21, almostLinear, fade"
                    "workspacesOut, 1, 1.94, almostLinear, fade"
                  ];
                };

              };
            };

        }).wrapper;
    };
}
