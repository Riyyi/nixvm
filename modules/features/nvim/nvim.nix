{
  flake.nixosModules.nvim = { config, pkgs, ... }:
  let
    user = config.preferences.user.name;
    home = config.preferences.user.home;

    files = [
      "init.lua"
      #"lazy-lock.json"

      "after/ftplugin/lua.lua"

      "lua/core/autocommands.lua"
      "lua/core/buffers.lua"
      "lua/core/config.lua"
      "lua/core/filetypes.lua"
      "lua/core/functions.lua"
      "lua/core/globals.lua"
      "lua/core/leader-key.lua"

      "lua/core.lua"
      "lua/development.lua"
      "lua/editor.lua"
      "lua/git.lua"
      "lua/keybind-functions.lua"
      "lua/keybinds.lua"
      "lua/packages.lua"
      "lua/selection.lua"
      "lua/terminal.lua"
      "lua/ui.lua"
    ];
  in
  {
    # Some additional packages needed for fzf compilation
    environment.systemPackages = with pkgs; [
      fzf
      gcc
      libgcc
      gnumake
      neovim
    ];

    hjem.users.${user} = {
      files =
        builtins.listToAttrs (map (file: {
          name = ".config/nvim/${file}";
          value = {
            source = ./dotfiles + "/${file}";
          };
        }) files)
        // {
          ".config/nvim/lua/nix.lua".text = ''
            vim.g.sqlite_clib_path = "${pkgs.sqlite.out}/lib/libsqlite3${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}"
          '';
        };
    };

    # lazy-lock.json wont be linked from Nix store, so it remains writable
    system.activationScripts.nvim = ''
      ln -sf ${home}/nixvm/modules/features/nvim/dotfiles/lazy-lock.json \
      	    "${home}/.config/nvim/lazy-lock.json"
    '';

  };
}

# TODO: Nvim dev:
# ln -s /home/rick/nixvm/modules/features/nvim/dotfiles ~/.config/nvim-dev
# cp ~/.config/nvim/lua/nix.lua ~/.config/nvim-dev/lua
# NVIM_APPNAME=nvim-dev nvim
