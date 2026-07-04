{
  homebrew = {
    enable = true;

    taps = [
      "leoafarias/fvm"
      "watari995/tap"
    ];

    brews = [
      "agent-browser"
      "anyenv"
      "asdf"
      "chezmoi"
      "cliclick"
      "cloudflared"
      "cocoapods"
      "fastlane"
      "fileicon"
      "freetds"
      "gemini-cli"
      "gnupg"
      "golang-migrate"
      "gradle"
      "leoafarias/fvm/fvm"
      "luarocks"
      "ni"
      "nvm"
      "openjdk@17"
      "proto"
      "python@3.12"
      "python@3.13"
      "rbenv"
      "rust"
      "screen"
      "semgrep"
      "sshpass"
      "subversion"
      "supabase"
      "watari995/tap/cc-preview"
      "xcodegen"
      "yarn"
    ];

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
