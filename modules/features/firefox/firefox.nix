{
  flake.nixosModules.firefox =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      user = config.preferences.user.name;
      home = config.preferences.user.home;

      files = [
        "profiles.ini"
        "dotfiles.profile/user.js"
        # BUG: Symlink both userContent.css and userChrome.css via directory
        # https://bugzilla.mozilla.org/show_bug.cgi?id=1384483#c4
        "dotfiles.profile/chrome"
      ];

      # Path has a hard-coded ID, found at:
      # https://gitlab.com/rycee/nur-expressions/-/blob/30a2e55fc20909b4b9e104e0254a2473184138a2/lib/mozilla.nix#L36
      path = "share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";

      mkExtension = package: id: area: {
        # https://mozilla.github.io/policy-templates/#extensionsettings
        "${id}" = {
          install_url = "file:///${pkgs.firefox-addons.${package}}/${path}/${id}.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
          temporarily_allow_weak_signatures = false;
          default_area = area;
        };
      };
    in
    {
      environment.systemPackages = with pkgs; [
        ff2mpv-go
        firefox
        mpv
        yt-dlp
      ];

      programs.firefox = {
        enable = true;
        package = pkgs.firefox;
        nativeMessagingHosts.packages = [ pkgs.ff2mpv-go ];

        policies.ExtensionSettings = {
          "*".installation_mode = "blocked"; # blocks all addons except specified below
        }
        // lib.mkMerge [
          # https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/generated-firefox-addons.nix
          (mkExtension "clearurls" "{74145f27-f039-47ce-a470-a662b129930a}" "menupanel")
          (mkExtension "decentraleyes" "jid1-BoFifL9Vbdl2zQ@jetpack" "menupanel")
          (mkExtension "fastforwardteam" "addon@fastforward.team" "menupanel")
          (mkExtension "ff2mpv" "ff2mpv@yossarian.net" "navbar")
          (mkExtension "tree-style-tab" "treestyletab@piro.sakura.ne.jp" "menupanel")
          (mkExtension "ublock-origin" "uBlock0@raymondhill.net" "navbar")
          (mkExtension "vimium" "{d7742d87-e61d-4b78-b8a1-b469842139fa}" "navbar")
          (mkExtension "violentmonkey" "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" "menupanel")
        ];
      };

      hjem.users.${user} = {
        files = builtins.listToAttrs (
          map (file: {
            name = ".config/mozilla/firefox/${file}";
            value = {
              source = ./dotfiles + "/${file}";
            };
          }) files
        );
      };

      # BUG: native-messaging-hosts *has* to be placed in ~/.mozilla
      system.activationScripts.ff2mpv = ''
        nmh="${home}/.mozilla/native-messaging-hosts"
        mkdir -p "$nmh"
        ${pkgs.ff2mpv-go}/bin/ff2mpv-go --manifest > "$nmh/ff2mpv.json"
        chown -R ${user}:users "$nmh"
      '';

    };
}
