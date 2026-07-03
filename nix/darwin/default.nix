{
  self,
  username,
  ...
}:
{
  imports = [
    ./homebrew.nix
    ./packages.nix
    ./system.nix
  ];

  nix.enable = false;
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  system = {
    configurationRevision = self.rev or self.dirtyRev or null;
    primaryUser = username;
    stateVersion = 6;
  };
}
