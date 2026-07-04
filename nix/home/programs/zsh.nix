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
      compinit -d "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
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

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "";
    };

    initContent = lib.mkMerge [
      (lib.mkBefore (
        (builtins.readFile ../../../zsh/banner.zsh)
        + ''
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
        ''
      ))
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
