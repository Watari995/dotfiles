{ config, ... }:
{
  xdg.configFile."ghostty".source = config.lib.file.mkOutOfStoreSymlink (
    "${config.home.homeDirectory}/ghq/github.com/Watari995/dotfiles/ghostty"
  );
}
