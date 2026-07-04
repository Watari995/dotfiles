# dotfiles

macOSの開発環境をNix、nix-darwin、Home Managerで管理するリポジトリです。

現在対応しているホストはApple Siliconの `MacBook-Pro-2` です。chezmoiと
`Brewfile` は移行完了まで残します。

## 初回セットアップ

1. Xcode Command Line Toolsをインストールする。

   ```sh
   xcode-select --install
   ```

2. Determinate Nixをインストールする。

   ```sh
   curl --proto '=https' --tlsv1.2 -sSf -L \
     https://install.determinate.systems/nix |
     sh -s -- install
   ```

3. リポジトリを所定のパスへ取得する。

   ```sh
   mkdir -p ~/ghq/github.com/Watari995
   git clone https://github.com/Watari995/dotfiles.git \
     ~/ghq/github.com/Watari995/dotfiles
   cd ~/ghq/github.com/Watari995/dotfiles
   ```

4. ビルドしてから適用する。

   ```sh
   nix run .#build
   nix run .#switch
   ```

`switch` は管理者パスワードを要求します。Homebrewの自動更新・アップグレード・
cleanupは無効にしているため、宣言にない既存アプリは削除しません。

## 日常の操作

### Nix設定を変更する

対象は `flake.nix` と `nix/` 以下です。

```sh
cd ~/ghq/github.com/Watari995/dotfiles
nix fmt
nix run .#build
nix run .#switch
git add -A
git commit -m "update nix configuration"
git push
```

- `build`: 実環境を変更せずにビルドする
- `switch`: ビルド済みの構成をmacOSとHome Managerへ適用する
- `update`: `flake.lock` の依存バージョンを更新する

依存更新時は次を実行します。

```sh
nix run .#update
nix run .#build
nix run .#switch
```

### Neovim設定を変更する

`~/.config/nvim` はリポジトリの `nvim/` への直接リンクです。Lua設定の変更は
即時反映されるため、通常は `switch` 不要です。

```sh
nvim ~/.config/nvim
cd ~/ghq/github.com/Watari995/dotfiles
git diff -- nvim
git add nvim
git commit -m "update Neovim configuration"
git push
```

Neovim本体、LSP、formatterなどNixパッケージを変更した場合は
`nix run .#build` と `nix run .#switch` も実行します。

### 別のMacで最新設定を反映する

```sh
cd ~/ghq/github.com/Watari995/dotfiles
git pull --ff-only
nix run .#build
nix run .#switch
```

`nvim/` や `ghostty/` の設定ファイルだけが変わった場合、直接リンクされている
ため `git pull` の時点で反映されます。

### zsh設定を変更する

- シェル初期化: `zsh/init.zsh`
- Powerlevel10k: `zsh/p10k.zsh`
- Home Manager設定: `nix/home/programs/zsh.nix`

`zsh/init.zsh` またはNix設定の変更後は、ビルドして適用します。

```sh
nix run .#build
nix run .#switch
exec zsh
```

### CLIパッケージ

共通CLIは `nix/home/packages.nix` で管理します。Neovim関連ツールなど、特定の
プログラムに属するCLIは `nix/home/programs/` の対応モジュールで管理します。

言語ランタイムとプロジェクト固有ツールは、共通CLIと分けて段階的に移行します。

## ディレクトリ

```text
.
├── flake.nix
├── flake.lock
├── nix/
│   ├── darwin/
│   ├── home/
│   └── hosts/
├── nvim/
├── ghostty/
└── zsh/
```

## ロールバック

過去のnix-darwin世代は次で確認できます。

```sh
darwin-rebuild --list-generations
```

世代のロールバックは、Homebrewアプリの削除やリポジトリ内の変更までは戻しません。
重要な変更はGitへコミットしてから適用してください。
