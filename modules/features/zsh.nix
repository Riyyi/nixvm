{
  inputs,
  self,
  ...
}:
{
  flake.nixosModules.zsh =
    {
      lib,
      pkgs,
      ...
    }:
    let
      zsh = self.packages.${pkgs.stdenv.hostPlatform.system}.zsh;
    in
    {
      programs.zsh.enable = true;

      programs.zsh.syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
        ];
        styles = lib.literalExpression ''
          {
            "path" = "fg=12,underline";
          }
        '';
      };

      environment.pathsToLink = [ "/share/zsh" ];

      environment.systemPackages = [
        zsh
        pkgs.zsh-history-substring-search
        pkgs.zsh-syntax-highlighting
      ];
    };

  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      switch-nixos = "sudo nixos-rebuild switch --sudo --flake .#$HOST";
      update-nixos = "sudo nix flake update --flake . && switch";
      clean-nixos = "sudo nix-env --delete-generations +5 --profile /nix/var/nix/profiles/system && nix-collect-garbage && nix-store --optimise";

      switch-darwin = "sudo darwin-rebuild switch --flake .#$HOST";
      update-darwin = "sudo nix flake update --flake . && switch";
      clean-darwin = "sudo nix-env --delete-generations +5 --profile /nix/var/nix/profiles/system && sudo nix-collect-garbage && sudo nix-store --optimise --ignore-failures";
    in
    {
      packages.zsh = inputs.wrapper-modules.wrappers.zsh.wrap {
        inherit pkgs;
        zshrc.content = ''
          ## Terminal

          # Disable Ctrl+S and Ctrl+Q
          stty -ixon

          # Use hard tabs
          stty tab0

          # Set tab width
          tabs -4

          # vi mode
          bindkey -v

          ## ZSH

          autoload -Uz promptinit colors vcs_info compinit history-search-end

          # Prompt
          promptinit
          colors
          setopt INTERACTIVE_COMMENTS
          setopt PROMPT_SUBST

          precmd() {
                vcs_info

                print -Pn "\e]0;%n@%m %~\a"
          }

          # ZSH parameters
          USR_HOST="%F{cyan}%n%f@%F{cyan}%m%f"
          DIRECTORY="%F{green}%~%f"
          ARROW="%(?..%F{red})➤%f"
          PROMPT='╭─''${USR_HOST} ''${DIRECTORY} ''${vcs_info_msg_0_}
          ╰─''${ARROW} '
          RPROMPT='%t'
          TIMEFMT=$"\nreal\t%*Es\nuser\t%*Us\nsys\t%*Ss"

          # Git
          zstyle ":vcs_info:*" enable git
          zstyle ":vcs_info:*" check-for-changes true
          zstyle ":vcs_info:*" stagedstr "%F{green}A%f"
          zstyle ":vcs_info:*" unstagedstr "%F{red}M%f"
          zstyle ":vcs_info:*" formats "%F{cyan}(%F{red}%b%F{cyan})%f %c%u"

          # Autocompletion
          compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
          zstyle ":completion::complete:*" use-cache 1
          zstyle ":completion::complete:*" cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
          zstyle ":completion:*:options" auto-description "%d"
          zstyle ":completion:*:default" list-colors ""
          zstyle ":completion:*:default" list-prompt ""
          zstyle ":completion:*" matcher-list "m:{a-zA-Z}={A-Za-z}" "r:|[._-]=* r:|=*" "l:|=* r:|=*"
          zstyle ":completion:*" menu select

          zstyle ":completion:*" group-name ""
          zstyle ":completion:*" list-dirs-first true
          zstyle ":completion:*" verbose yes
          zstyle ":completion:*:default" list-prompt "%S%M matches%s"
          zstyle ":completion:*:matches" group "yes"
          zstyle ":completion:*:options" description "yes"

          # Completion formatting
          zstyle ":completion:*" format " %F{yellow}-- %d --%f"
          zstyle ":completion:*:corrections" format " %F{green}-- %d (errors: %e) --%f"
          zstyle ":completion:*:descriptions" format " %F{yellow}-- %d --%f"
          zstyle ":completion:*:messages" format " %F{purple} -- %d --%f"
          zstyle ":completion:*:warnings" format " %F{red}-- no matches found --%f"

          # Bind keys
          zle -N history-beginning-search-backward-end history-search-end
          zle -N history-beginning-search-forward-end history-search-end

          bindkey "\eOc" forward-word                               # ctrl-right
          bindkey "\e[1;5C" forward-word                            # ctrl-right
          bindkey "\eOd" backward-word                              # ctrl-left
          bindkey "\e[1;5D" backward-word                           # ctrl-left
          bindkey "\e[3~" delete-char                               # del
          bindkey "\e[7~" beginning-of-line                         # home
          bindkey "\e[H" beginning-of-line                          # home
          bindkey "\eOH" beginning-of-line                          # home
          bindkey "\e[8~" end-of-line                               # end
          bindkey "\e[F" end-of-line                                # end
          bindkey "\eOF" end-of-line                                # end
          bindkey "\e[A" history-beginning-search-backward-end      # up
          bindkey "\eOA" history-beginning-search-backward-end      # up
          bindkey "\e[B" history-beginning-search-forward-end       # down
          bindkey "\eOB" history-beginning-search-forward-end       # down
          bindkey "\e[Z" reverse-menu-complete                      # shift-tab
          bindkey "\eh" kill-whole-line                             # meta-h
          bindkey "\ej" history-beginning-search-forward-end        # meta-j
          bindkey "\ek" history-beginning-search-backward-end       # meta-k
          bindkey "\el" accept-line                                 # meta-l
          bindkey "^R" history-incremental-pattern-search-backward  # ctrl-r

          # History
          setopt APPEND_HISTORY
          setopt EXTENDED_HISTORY
          setopt HIST_FIND_NO_DUPS
          setopt HIST_IGNORE_ALL_DUPS
          setopt HIST_IGNORE_DUPS
          setopt HIST_REDUCE_BLANKS
          setopt HIST_SAVE_NO_DUPS
          #HISTFILE="$XDG_CACHE_HOME/zsh/zsh_history" #TODO
          HISTSIZE=10000
          SAVEHIST=10000

          # HACK: Prevent blinking cursor in Ghostty
          # https://github.com/ghostty-org/ghostty/discussions/2812#discussioncomment-12419014
          function __set_beam_cursor { echo -ne '\e[6 q' }
          function __set_block_cursor { echo -ne '\e[2 q' }
          function zle-keymap-select {
            case $KEYMAP in
              vicmd) __set_block_cursor;;
              viins|main) __set_beam_cursor;;
            esac
          }
          zle -N zle-keymap-select
          precmd_functions+=(__set_beam_cursor)

          [ -f "$ZDOTDIR/.zshrc_extended" ] && source "$ZDOTDIR/.zshrc_extended" #TODO: Set ZDOTDIR/pull from other path
        '';

        zshAliases = {
          ## Aliases

          # General
          ".." = "cd ..";
          "..." = "cd ../..";
          "..2" = "cd ../..";
          "..3" = "cd ../../..";
          "..4" = "cd ../../../..";
          cp = "cp -i";
          df = "df -h";
          diff = "diff --color";
          du = "du -h";
          e = "aliases emacs";
          emacs = "aliases emacs";
          fuck = "sudo $(fc -ln -1)";
          grep = "grep --color=always";
          ip = "ip --color";
          ipb = "ip --color --brief a";
          "l." =
            "\ls -lAGh --color --group-directories-first --hyperlink | awk '{ if (\$NF ~ /^( .*m)?\./) print }'";
          la = "\ls -lAGh --color --group-directories-first --hyperlink";
          less = "less -x 4";
          ls = "ls --color --group-directories-first --hyperlink";
          mkdir = "mkdir -pv";
          mv = "mv -i";
          pkill = "pkill -9";
          q = "exit";
          rm = "rm -i";
          se = "sudoedit";
          semacs = "sudoedit";
          ss = "sudo systemctl";
          v = "vim --servername VIM";
          vim = "vim --servername VIM";

          # Git
          g = "git";
          ga = "git add";
          gap = "git add -p";
          gb = "git branch";
          gc = "git commit";
          gch = "git checkout";
          gd = "git diff";
          gdc = "git diff --cached";
          gds = "git diff --staged";
          gf = "git fetch";
          gl = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%ai%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d    %C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
          gle = "git log --graph --stat --format=format:'%C(bold blue)commit %H%C(reset)%C(bold yellow)%d %C(reset)%nAuthor: %C(dim white)%an <%ae>%C(reset)%nDate:   %C(bold cyan)%ai%C(reset) %C(bold green)(%ar)%C(reset)%n%n%w(64,4,4)%B'";
          gm = "git merge";
          gp = "git pull";
          gps = "git push || git push origin $(git branch --show-current)";
          gpsa = "git remote | xargs -I remotes git push remotes $(git branch --show-current)";
          gpsaf = "git remote | xargs -I remotes git push --force remotes $(git branch --show-current)";
          gr = "git reset";
          gs = "git status";
          gsh = "git show --format=format:'%C(bold blue)commit %H%C(reset) %C(bold yellow)%d %C(reset)%nAuthor: %C(dim white)%an <%ae>%C(reset)%nDate:   %C(bold cyan)%ai%C(reset) %C(bold green)(%ar)%C(reset)%n%n%w(64,4,4)%B'";
          gt = "git ls-tree -r --name-only $(git branch --show-current) .";

          # NixOS
          list = "nixos-rebuild list-generations";
          switch =
            if system != "x86_64-darwin" && system != "aarch64-darwin" then switch-nixos else switch-darwin;
          update =
            if system != "x86_64-darwin" && system != "aarch64-darwin" then update-nixos else update-darwin;
          clean =
            if system != "x86_64-darwin" && system != "aarch64-darwin" then clean-nixos else clean-darwin;

          # Applications
          mpv-window = "nohup mpv --idle --force-window >/dev/null 2>&1 &";
          neofetch = "fastfetch -c neofetch";
        };

        zshenv.content = ''
          # Directories
          export FPATH="$FPATH:$HOME/.local/completion"
          export PATH="$PATH:$HOME/.local/bin"
          export XDG_CACHE_HOME="$HOME/.cache"
          export XDG_CONFIG_HOME="$HOME/.config"
          export XDG_DATA_HOME="$HOME/.local/share"
          export XDG_STATE_HOME="$HOME/.local/state"
          mkdir -p "$XDG_CACHE_HOME/zsh"

          # Editor
          export ALTERNATE_EDITOR=""
          export EDITOR="nvim"
          export VISUAL="nvim"

          # Files
          export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"

          # GPG
          export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"

          # Gradle
          export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"

          # Less
          export LESS="-R"
          export LESSHISTFILE="-"
          export LESS_TERMCAP_mb="$(printf '%b' '\e[01;31m')"     # begin blink
          export LESS_TERMCAP_md="$(printf '%b' '\e[01;34m')"     # begin bold
          export LESS_TERMCAP_me="$(printf '%b' '\e[0m')"         # reset blink/bold
          export LESS_TERMCAP_so="$(printf '%b' '\e[01;107;30m')" # begin reverse video
          export LESS_TERMCAP_se="$(printf '%b' '\e[0m')"         # reset reverse video
          export LESS_TERMCAP_us="$(printf '%b' '\e[04;95m')"     # begin underline
          export LESS_TERMCAP_ue="$(printf '%b' '\e[0m')"         # reset underline

          # ls (LS_COLORS)
          eval "$(dircolors -b)"

          # Make
          export MAKEFLAGS="-j $(getconf _NPROCESSORS_ONLN)"

          # npm
          export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"

          # OpenSSL
          export RANDFILE="$XDG_CACHE_HOME/rnd"

          # Python
          export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"

          # Rust
          export CARGO_HOME="$XDG_DATA_HOME/cargo"
          export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

          # Terminal
          export TERMINAL="ghostty"

          # Web browser
          export BROWSER="firefox"

          # Wget
          export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

          # Wine
          export WINEPREFIX="$XDG_DATA_HOME/wine"
        '';
      };
    };
}
