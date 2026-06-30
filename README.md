# dotfiles

macOS 開発環境の設定ファイル一式。[chezmoi](https://chezmoi.io) で管理。

## 管理対象

- Neovim (`~/.config/nvim/`)
- Ghostty (`~/.config/ghostty/`)
- zsh (`~/.zshrc`)
- Powerlevel10k (`~/.p10k.zsh`)
- Raycast スクリプト・アイコン (`~/.config/raycast/`)
- Homebrew パッケージ (`Brewfile`)

## 新しい PC へのセットアップ

### 1. Homebrew をインストール

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. chezmoi で設定を適用

```bash
brew install chezmoi
chezmoi init --apply https://github.com/Watari995/dotfiles
```

### 3. Homebrew パッケージを一括インストール

```bash
brew bundle --file=$(chezmoi source-path)/Brewfile
```

### 4. Raycast の設定を同期

Raycast を起動 → Settings → Cloud Sync からサインインする。

## 設定を更新したとき

```bash
chezmoi add <変更したファイルのパス>
cd ~/.local/share/chezmoi
git add -A && git commit -m "update dotfiles"
git push
```
