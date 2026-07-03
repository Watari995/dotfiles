{
  config,
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      lazygit
      lua-language-server
      neovim
      stylua
      tree-sitter
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    shellAliases = {
      vi = "nvim";
      vim = "nvim";
    };
  };

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink (
    "${config.home.homeDirectory}/ghq/github.com/Watari995/dotfiles/nvim"
  );
}
