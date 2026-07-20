# Fonts

このリポジトリでは、フォントを次の方針で管理します。

```text
OSSフォント: Nix / Home Manager
有料フォント: 手動で ~/Library/Fonts に配置
アプリ設定: dotfiles に記録
```

## 現在の基本構成

```text
英数字/code: Berkeley Mono
アイコン: Symbols Nerd Font Mono
日本語: UDEV Gothic
```

Ghostty の現在設定:

```conf
font-family = Berkeley Mono
font-family = Symbols Nerd Font Mono
font-family = UDEV Gothic
font-family-bold = Berkeley Mono Bold
font-family-italic = Berkeley Mono Oblique
font-family-bold-italic = Berkeley Mono Bold Oblique
font-size = 14
```

`font-thicken` は指定しません。Ghostty のデフォルトは `false` です。

## Nixで管理するフォント

日本語 fallback の `UDEV Gothic` は Nix で管理します。

対象ファイル:

```text
nix/home/packages.nix
```

追加済み:

```nix
udev-gothic
```

変更後は次を実行します。

```sh
cd ~/ghq/github.com/Watari995/dotfiles
nix run .#build
nix run .#switch
```

確認:

```sh
ghostty +list-fonts | rg -i "UDEV"
```

## Berkeley Mono

Berkeley Mono は有料フォントなので Nix 管理に入れません。購入後に生成した OTF を
ユーザーフォントへ配置します。

重要: 別の Mac でこの dotfiles を適用しても、Berkeley Mono は自動では入りません。
`nix run .#switch` で入るのは Nix 管理している OSS フォントだけです。新しい Mac で
Ghostty を同じ見た目にするには、その Mac にも購入済みの Berkeley Mono OTF を
別途配置します。

```sh
cp ~/Downloads/<berkeley-dir>/*.otf ~/Library/Fonts/
fc-cache -f
```

確認:

```sh
ghostty +list-fonts | rg -i "Berkeley"
ghostty +show-face --string='func main() error'
```

期待値:

```text
Berkeley Mono
```

Berkeley Mono が入っていない状態で Ghostty を起動すると、設定上は
`Berkeley Mono` を要求しますが、実際の表示は次の fallback に落ちます。そのため
見た目が別の Mac と変わります。

## Fallback順

他のエディタやターミナルへ展開するときも、基本はこの順にします。

```text
Berkeley Mono
Symbols Nerd Font Mono
UDEV Gothic
```

理由:

- Berkeley Mono は英数字とコード記号を担当する
- Symbols Nerd Font Mono はプロンプトやファイルアイコンを担当する
- UDEV Gothic は日本語を担当する

`Hiragino Sans W5` は必須ではありません。文字欠けが出た場合だけ最後に追加します。

```text
Berkeley Mono
Symbols Nerd Font Mono
UDEV Gothic
Hiragino Sans W5
```

## エディタ別メモ

### Ghostty

設定ファイル:

```text
ghostty/config
```

設定変更後は Ghostty を再起動します。

確認:

```sh
ghostty +validate-config --config-file=~/ghq/github.com/Watari995/dotfiles/ghostty/config
ghostty +show-face --string='func main() error 日本語 '
```

### Cursor / VS Code

今後適用する場合の候補:

```json
{
  "editor.fontFamily": "Berkeley Mono, Symbols Nerd Font Mono, UDEV Gothic, monospace",
  "terminal.integrated.fontFamily": "Berkeley Mono, Symbols Nerd Font Mono, UDEV Gothic, monospace",
  "editor.fontLigatures": true
}
```

### Neovim

Neovim 自体は GUI フォントを持ちません。Ghostty 内で使う場合は Ghostty の設定が
反映されます。

Neovim GUI を使う場合だけ、GUI 側のフォント設定を別途追加します。

## Ligatures

`!=` などの変換は ligature です。Berkeley Mono 公式は ligature あり版を提供して
いますが、生成したフォントに ligature が入っている必要があります。

Ghostty 側で ligature を明示する場合:

```conf
font-feature = calt
font-feature = liga
```

無効化する場合:

```conf
font-feature = -calt
font-feature = -liga
font-feature = -dlig
```

Go では ligature は好みです。正確な文字列を常に見たい場合は無効、見た目を整えたい
場合は有効にします。
