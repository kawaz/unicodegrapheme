///|
/// Unicode grapheme cluster の境界情報を保持するビュー型。
/// 元の String のゼロコピースライスとして各 grapheme cluster にアクセスできる。
pub struct GraphemeView {
  priv source : String
  priv boundaries : Array[Int] // 各 cluster の開始オフセット（末尾は文字列終端）
}

///|
/// 文字列を grapheme cluster 単位で分割した GraphemeView を返す。
/// UAX #29 の GB ルール群をステートマシンで実装。
pub fn graphemes(s : String) -> GraphemeView {
  let boundaries : Array[Int] = []
  let mut offset = 0
  let mut prev_gcb : GCBCategory? = None
  let mut ri_count = 0
  let mut emoji_state : EmojiState = ES_None
  let mut incb_state : InCBState = IC_None
  for ch in s {
    let cp = ch.to_int()
    let cur_gcb = gcb_category(cp)
    // GB1: sot ÷ Any — 最初のコードポイントは無条件で境界
    let is_boundary = match prev_gcb {
      None => true
      Some(prev) => check_boundary(prev, cur_gcb, ri_count, emoji_state, incb_state)
    }
    if is_boundary {
      boundaries.push(offset)
    }
    // 状態更新
    // ri_count
    ri_count = if cur_gcb == Regional_Indicator { ri_count + 1 } else { 0 }
    // emoji_state
    emoji_state = if cur_gcb == Extended_Pictographic {
      // GB11 が成立した場合（ES_EP_Extend_ZWJ && cur == EP）も新しいEP列の開始
      ES_EP_Seen
    } else if emoji_state == ES_EP_Seen && cur_gcb == Extend {
      ES_EP_Seen // Extend を跨いで維持
    } else if emoji_state == ES_EP_Seen && cur_gcb == ZWJ {
      ES_EP_Extend_ZWJ
    } else {
      ES_None
    }
    // incb_state
    incb_state = if cur_gcb == InCB_Consonant {
      // GB9c が成立した場合も新しい Consonant 列の開始
      IC_Consonant_Seen
    } else if incb_state != IC_None && is_incb_linker(cp) {
      IC_Consonant_Linker_Seen
    } else if incb_state != IC_None && is_incb_extend(cp) {
      incb_state // 維持
    } else {
      IC_None
    }
    // prev_gcb 更新
    prev_gcb = Some(cur_gcb)
    // UTF-16 オフセットを進める
    offset = offset + (if cp >= 0x10000 { 2 } else { 1 })
  }
  // GB2: Any ÷ eot — 文字列末尾
  if boundaries.length() > 0 {
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
