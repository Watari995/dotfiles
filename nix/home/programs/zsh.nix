{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    completionInit = ''
      autoload -U compinit
      mkdir -p "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
      zcompdump="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
      if [[ -s "$zcompdump" ]]; then
        compinit -C -d "$zcompdump"
      else
        compinit -d "$zcompdump"
      fi
      unset zcompdump
    '';

    history = {
      append = true;
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 10000;
      size = 10000;
      share = true;
    };

    plugins = [
      {
        name = "git";
        src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git";
        file = "git.plugin.zsh";
      }
    ];

    profileExtra = ''
      # nix-darwin and Home Manager provide PATH entries through /etc/zprofile.
      # Do not run `brew shellenv` here because it would override Nix packages.
    '';

    initContent = lib.mkMerge [
      (lib.mkBefore (builtins.readFile ../../../zsh/banner.zsh))
      (builtins.readFile ../../../zsh/init.zsh)
      (lib.mkAfter ''
        source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
        [[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"
      '')
    ];
  };

  home.file.".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink (
    "${config.home.homeDirectory}/ghq/github.com/Watari995/dotfiles/zsh/p10k.zsh"
  );
}
