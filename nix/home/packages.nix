{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cmake
    cspell
    fd
    ffmpeg
    fzf
    gawk
    gh
    git-lfs
    gnupg
    imagemagick
    jq
    starship
    pandoc
    poppler-utils
    protobuf
    qpdf
    ripgrep
    tmux
    udev-gothic
  ];
}
