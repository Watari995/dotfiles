# dotfiles

macOS 開発環境の設定ファイル一式。[chezmoi](https://chezmoi.io) で管理。

## 管理対象

- Neovim (`~/.config/nvim/`) ※ 別リポジトリ [nvim.conf](https://github.com/Watari995/nvim.conf) で管理
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

インストール後、PATH に追加する（表示されるコマンドをそのまま実行）：

```bash
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
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

サードパーティ tap を信頼してから再実行すると失敗が減る：

```bash
brew trust ariga/tap bufbuild/buf cloudflare/cloudflare heroku/brew leoafarias/fvm mobile-dev-inc/tap osx-cross/arm osx-cross/avr qmk/qmk revylai/tap shivammathur/php stripe/stripe-cli supabase/tap
brew bundle --file=$(chezmoi source-path)/Brewfile
```

### 4. Oh My Zsh をインストール

> ⚠️ `.zshrc` の上書きを聞かれたら **N** を押す

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 5. Powerlevel10k テーマと zsh プラグインをインストール

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 6. anyenv を初期化

```bash
anyenv install --init
anyenv install nodenv
```

### 7. Neovim 設定をクローン

```bash
git clone https://github.com/Watari995/nvim.conf.git ~/.config/nvim
```

Neovim を起動すると Lazy.nvim がプラグインを自動インストールする。  
Treesitter パーサーは Neovim 内で `:TSInstall all` を実行。

### 8. Claude Code をインストール

```bash
npm install -g @anthropic-ai/claude-code
```

### 9. Raycast の設定を同期

Raycast を起動 → Settings → Cloud Sync からサインインする。

### 10. シェルを再起動

```bash
exec zsh
```

---

## プロジェクトごとの言語バージョン設定

asdf はプロジェクトの `.tool-versions` に従ってバージョンを管理する。  
プロジェクトに入ったとき、指定バージョンが未インストールなら：

```bash
asdf install  # .tool-versions に書かれた全バージョンをインストール
```

---

## 設定を更新したとき

```bash
chezmoi add <変更したファイルのパス>
cd ~/.local/share/chezmoi
git add -A && git commit -m "update dotfiles"
git push
```
