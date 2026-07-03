{
  username,
  ...
}:
{
  imports = [
    ./packages.nix
    ./programs/neovim.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
