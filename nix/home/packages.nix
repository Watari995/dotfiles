{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cmake
    fd
    ffmpeg
    fzf
    gawk
    gh
    git-lfs
    gnupg
    imagemagick
    jq
    pandoc
    poppler-utils
    protobuf
    qpdf
    ripgrep
    tmux
  ];
}
