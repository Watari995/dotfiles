{
  config,
  lib,
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

    profileExtra = ''
      # nix-darwin and Home Manager provide PATH entries through /etc/zprofile.
      # Do not run `brew shellenv` here because it would override Nix packages.
    '';

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        source "${config.home.homeDirectory}/ghq/github.com/Watari995/dotfiles/zsh/banner.zsh"
      '')
      (builtins.readFile ../../../zsh/init.zsh)
      (lib.mkAfter ''
        eval "$(starship init zsh)"
      '')
    ];
  };

  xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink (
    "${config.home.homeDirectory}/ghq/github.com/Watari995/dotfiles/dot_config/starship.toml"
  );
}
