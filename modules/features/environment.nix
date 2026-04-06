{ inputs, self, ... }:
{
  # Module for TTY purposes

  flake.nixosModules.environment = {

    imports = [
      self.nixosModules.git
      self.nixosModules.nvim
      self.nixosModules.zsh
    ];

  };

  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    {

      packages.environment = inputs.wrapper-modules.lib.wrapPackage {
        inherit pkgs;
        package = self'.packages.zsh;
        extraPackages = with pkgs; [
          coreutils
          fastfetch
          git
          htop
          imagemagick
          jq
          stable.neovim
          nixd
          nixfmt
          nixfmt-tree
          self'.packages.ns
          openssh
          ripgrep
          rsync
          tokei
          tree
          util-linux
          wget
          yt-dlp
        ];
      };

    };
}
