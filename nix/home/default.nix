{
  username,
  ...
}:
{
  imports = [
    ./packages.nix
    ./programs/direnv.nix
    ./programs/ghostty.nix
    ./programs/neovim.nix
    ./programs/zsh.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
