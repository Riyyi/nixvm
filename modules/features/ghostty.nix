{ self, inputs, ... }:
{

  perSystem =
    { pkgs, ... }:
    {

      packages.ghostty =
        (inputs.wrappers.wrapperModules.ghostty.apply {
          inherit pkgs;

          settings = {
            app-notifications = "no-clipboard-copy";
            confirm-close-surface = false;
            copy-on-select = "clipboard";
            cursor-style-blink = false;
            font-family = "NotoSansM Nerd Font Mono";
            font-feature = "-calt, -liga, -dlig"; # disable ligatures
            font-size = 12;
            link-url = true;
            macos-titlebar-style = "hidden";
            selection-invert-fg-bg = true;
            shell-integration-features = "no-cursor";
            term = "xterm-256color";
            theme = "noctalia";
            window-decoration = true;
            window-inherit-working-directory = true;

            keybind = [
              "super+d=unbind"
              "super+t=unbind"
              "super+w=unbind"

              # Neovim fixes:

              # forward command + backtick the <C-6> (Ctrl-^) sequence
              "super+grave_accent=text:\\x1E"
              # make command + h work
              "unconsumed:super+h=text:h"
            ];
          };
        }).wrapper;

    };
}
