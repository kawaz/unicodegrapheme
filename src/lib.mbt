///|
/// Unicode grapheme cluster の境界情報を保持するビュー型。
/// 元の String のゼロコピースライスとして各 grapheme cluster にアクセスできる。
pub struct GraphemeView {
  // TODO: 内部実装
  // - source: String（元の文字列）
  // - boundaries: Array[Int]（grapheme cluster 境界の UTF-16 オフセット）
  priv source : String
  priv boundaries : Array[Int] // 各 cluster の開始オフセット（末尾は文字列終端）
}

///|
/// 文字列を grapheme cluster 単位で分割した GraphemeView を返す。
pub fn graphemes(s : String) -> GraphemeView {
  // TODO: UAX #29 ステートマシンによる境界検出を実装
  // 暫定: コードポイント単位で分割（サロゲートペア対応のみ）
  let boundaries : Array[Int] = [0]
  let mut offset = 0
  for ch in s {
    offset += if ch.to_int() >= 0x10000 { 2 } else { 1 }
    boundaries.push(offset)
  }
  { source: s, boundaries }
}

///|
/// grapheme cluster の数を返す。
pub fn GraphemeView::length(self : GraphemeView) -> Int {
  if self.boundaries.length() <= 1 {
    0
  } else {
    self.boundaries.length() - 1
  }
}

///|
/// i 番目の grapheme cluster を StringView として返す。
pub fn GraphemeView::op_get(
  self : GraphemeView,
  i : Int
) -> StringView {
  let start = self.boundaries[i]
  let end = self.boundaries[i + 1]
  self.source.view(start_offset=start, end_offset=end)
}

///|
/// grapheme cluster を順にイテレートする。
pub fn GraphemeView::iter(self : GraphemeView) -> Iter[StringView] {
  let len = self.length()
  let mut i = 0
  Iter::new(fn() {
    if i >= len {
      None
    } else {
      let result = self[i]
      i += 1
      Some(result)
    }
  })
}
