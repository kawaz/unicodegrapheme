# ドキュメント i18n ルール

## 原本は常に -ja.md

- `README-ja.md` と `DESIGN-ja.md` が原本（日本語）
- `README.md` と `DESIGN.md` は英語版（publish 向け）
- publish のタイミングで 日→英 の同期を行う
- 英語版は原本の翻訳であり、独自の内容を追加しない

## md ファイルのヘッダ

各 md ファイルの先頭に相互リンクを入れる:

```markdown
English | [日本語](README-ja.md)
```

```markdown
[English](README.md) | 日本語
```
