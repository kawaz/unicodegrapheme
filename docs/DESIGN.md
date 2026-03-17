# unicodegrapheme 設計

## 目的

MoonBit で Unicode grapheme cluster 単位の文字列操作を提供する。

## アーキテクチャ

### GraphemeView

元の String を保持し、grapheme cluster の境界オフセット配列を持つ。
各 cluster へのアクセスは StringView（ゼロコピースライス）で返す。

```
GraphemeView {
  source: String              // 元の文字列（所有）
  boundaries: Array[Int]      // 各 cluster の開始 UTF-16 オフセット
}                              // boundaries[length] = source.length()
```

### UAX #29 実装方針

1. `Grapheme_Cluster_Break` プロパティテーブル — Unicode 16.0.0 の `GraphemeBreakProperty.txt` から生成
2. `Extended_Pictographic` プロパティ — `emoji-data.txt` から生成
3. テーブル生成 — Python or Rust スクリプトで `.mbt` ファイルを自動生成
4. ステートマシン — UAX #29 の GB ルール群を状態遷移テーブルで実装

### 3層の Unicode 問題と本ライブラリの位置

| レイヤー | 問題 | 解決 |
|----------|------|------|
| L1: UTF-16 encoding | `str[i]` がコードユニット単位 | MoonBit core の `iter()` / `char_length()` |
| **L2: Grapheme cluster** | 合成絵文字が複数コードポイント | **本ライブラリ** |
| L3: Display width | 全角/半角の表示幅 | `rami3l/unicodewidth` |

### 段階的実装

1. **Phase 0（現在）**: コードポイント単位の暫定実装。サロゲートペアは正しく処理。
2. **Phase 1**: `Grapheme_Cluster_Break` テーブル生成 + 基本ルール実装
3. **Phase 2**: `Extended_Pictographic` + 絵文字シーケンス対応
4. **Phase 3**: パフォーマンス最適化、追加 API（スライス、逆イテレーション等）

## 参考

- [UAX #29: Unicode Text Segmentation](https://unicode.org/reports/tr29/)
- [Rust unicode-segmentation](https://github.com/unicode-rs/unicode-segmentation)
- [moonbit-community/unicode_data](https://github.com/moonbit-community/unicode_data)
- [rami3l/unicodewidth](https://github.com/moonbit-community/unicodewidth.mbt)
