{
  homebrew = {
    enable = true;

    taps = [
      "leoafarias/fvm"
      "watari995/tap"
    ];

    brews = [
      "asdf"
      "cliclick"
      "cloudflared"
      "cocoapods"
      "fastlane"
      "fileicon"
      "terminal-notifier"
      "freetds"
      "gemini-cli"
      "golang-migrate"
      "gradle"
      "leoafarias/fvm/fvm"
      "luarocks"
      "ni"
      "openjdk@17"
      "python@3.12"
      "python@3.13"
      "rust"
      "screen"
      "semgrep"
      "ripgrep"
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
