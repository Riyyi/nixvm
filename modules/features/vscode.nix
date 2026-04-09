{
  flake.nixosModules.vscode =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      user = config.preferences.user.name;
    in
    {

      environment.systemPackages = with pkgs.stable; [
        (vscode-with-extensions.override {
          vscode = vscode-fhs;
          vscodeExtensions =
            with vscode-extensions;
            [
              bradlc.vscode-tailwindcss
              dbaeumer.vscode-eslint
              eamodio.gitlens
              firefox-devtools.vscode-firefox-debug
              github.copilot-chat
              vscodevim.vim
              vue.volar
            ]
            ++ vscode-utils.extensionsFromVscodeMarketplace [
              # {
              #   name = "noctaliatheme";
              #   publisher = "noctalia";
              #   version = "0.0.5";
              #   sha256 = "aTSk3yYkBw5GrD0CbRL2wo3SlBffzBTDe1pZoZa1URQ=";
              # }
              {
                name = "goto-alias";
                publisher = "antfu";
                version = "1.0.0";
                sha256 = "24JYijk7K1OKwRzWQnhZE98UxrWduIujDj868TNBiYQ=";
              }
              {
                name = "iconify";
                publisher = "antfu";
                version = "1.0.0";
                sha256 = "Z36ZgkHabbHz0n3V+LdsuN7LT4exWuB+chkMcFwgtpM=";
              }
              {
                name = "markdowntable";
                publisher = "takumiI";
                version = "0.13.0";
                sha256 = "N1FZbDFiX5S+qKrtWpA+zGUhC81db5JiqcSPxeHmkhE=";
              }
              {
                name = "mdc";
                publisher = "Nuxt";
                version = "0.5.0";
                sha256 = "utSIlWOmvlTYuE/GoogNx13wIvjVTJ5LH81N0lJdfJE=";
              }
              {
                name = "nuxtr-vscode";
                publisher = "Nuxtr";
                version = "0.2.16";
                sha256 = "DVoq8zdlJ2ch8PCG34f1PRkILym9XdclUHQ9s2B5OME=";
              }
              {
                name = "Theme-TomorrowKit";
                publisher = "ms-vscode";
                version = "0.1.4";
                sha256 = "qakwJWak+IrIeeVcMDWV/fLPx5M8LQGCyhVt4TS/Lmc=";
              }
              {
                name = "vscode-pbkit";
                publisher = "pbkit";
                version = "0.0.8";
                sha256 = "xM6yKLx9rntZZO0VMGrpyvIFhNAV5pFWIFrUqKglZyI=";
              }
            ];
        })
      ];

      hjem.users.${user}.files = {
        ".vscode/argv.json" = {
          generator = lib.generators.toJSON { };
          value = {
            enable-crash-reporter = false;
            # https://code.visualstudio.com/docs/configure/settings-sync#_recommended-configure-the-keyring-to-use-with-vs-code
            password-store = "gnome-libsecret"; # make gnome-keyring work
          };
        };
        ".config/Code/User/settings.json" = {
          generator = lib.generators.toJSON { };
          value = {
            editor.cursorBlinking = "solid";
            editor.rulers = [ 80 ];
            editor.trimWhitespaceOnDelete = true;
            files.insertFinalNewline = true;
            files.trimFinalNewlines = true;
            files.trimTrailingWhitespace = true;
            gitlens.ai.model = "vscode";
            gitlens.ai.vscode.model = "copilot:claude-haiku-4.5";
            vim.useSystemClipboard = true;
            workbench.colorTheme = "Tomorrow Night";
          };
        };
      };

    };
}
