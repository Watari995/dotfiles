# Welcome banner
printf '\033[1;37m              _       __      __             _ ____  ____  ______\n'
printf '\033[0;36m════════════\033[1;37m | |     / /___ _/ /_____ ______(_) __ \/ __ \/ ____/\n'
printf '\033[0;36m  ══════════\033[1;37m | | /| / / __ `/ __/ __ `/ ___/ / /_/ / /_/ /___ \\  \n'
printf '\033[0;36m    ════════\033[1;37m | |/ |/ / /_/ / /_/ /_/ / /  / /\__, /\__, /___/ /  \n'
printf '\033[1;37m             |__/|__/\__,_/\__/\__,_/_/  /_//____//____/_____/\033[0m\n\n'
printf '\e]12;#FFFFFF\a'

# Keep PATH entries unique while legacy version managers are being consolidated.
typeset -U path PATH

export GOPATH="$HOME/go"
export PNPM_HOME="$HOME/Library/pnpm"
export ASDF_DATA_DIR="$HOME/.asdf"

[[ -d "$HOME/.anyenv/bin" ]] && path=("$HOME/.anyenv/bin" $path)
if (( $+commands[anyenv] )); then
  eval "$(anyenv init -)"
fi

[[ -d "$ASDF_DATA_DIR/shims" ]] && path=("$ASDF_DATA_DIR/shims" $path)
[[ -d "$PNPM_HOME" ]] && path=("$PNPM_HOME" $path)
[[ -d "$HOME/.volta/bin" ]] && path=("$HOME/.volta/bin" $path)
[[ -d "$HOME/.cargo/bin" ]] && path=("$HOME/.cargo/bin" $path)
[[ -d "$GOPATH/bin" ]] && path=("$GOPATH/bin" $path)

path+=(
  /Applications/MySQLWorkbench.app/Contents/Resources/utilities
  /usr/local/bin
  /usr/local/sbin
  /usr/local/mysql/bin
  /System/Volumes/Data/opt/homebrew/share/google-cloud-sdk/bin
)

if (( $+commands[rbenv] )); then
  eval "$(rbenv init - zsh)"
fi

[[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]] &&
  source "$HOME/.dart-cli-completion/zsh-config.zsh"

alias cs='claude --dangerously-skip-permissions'
alias co='codex --yolo'
alias gc='git checkout'
alias gcb='git checkout -b'
alias gp='git push'
alias gpl='git pull'
