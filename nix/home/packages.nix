{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fd
    jq
    ripgrep
  ];
}
