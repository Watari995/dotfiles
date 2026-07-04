{
  homebrew = {
    enable = true;

    casks = [
      "codex"
      "docker-desktop"
      "dotnet-sdk"
      "flutter"
      "font-blex-mono-nerd-font"
      "font-hackgen-nerd"
      "font-jetbrains-mono"
      "font-jetbrains-mono-nerd-font"
      "gcloud-cli"
      "hammerspoon"
      "maestro"
      "ngrok"
      "raspberry-pi-imager"
      "tailscale-app"
      "visual-studio-code"
      "wezterm@nightly"
    ];

    onActivation = {
      autoUpdate = false;
      cleanup = "none";
      upgrade = false;
    };
  };
}
