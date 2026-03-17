///|
/// Unicode UAX #29 Grapheme Cluster Break (GCB) カテゴリ。
/// コードポイントごとに割り当てられ、grapheme cluster 境界判定に使用する。
priv enum GCBCategory {
  Other
  CR
  LF
  Control
  Extend
  ZWJ
  Regional_Indicator
  Prepend
  SpacingMark
  L // Hangul Leading Jamo
  V // Hangul Vowel Jamo
  T // Hangul Trailing Jamo
  LV // Hangul LV Syllable
  LVT // Hangul LVT Syllable
  Extended_Pictographic
  InCB_Consonant
} derive(Eq, Show)

///|
/// コードポイントの GCB カテゴリを返す（テーブルにない場合は Other）
fn gcb_category(cp : Int) -> GCBCategory {
  let mut lo = 0
  let mut hi = gcb_table.length() - 1
  while lo <= hi {
    let mid = (lo + hi) / 2
    let (start, end, cat) = gcb_table[mid]
    if cp < start {
      hi = mid - 1
    } else if cp > end {
      lo = mid + 1
    } else {
      return cat
    }
  }
  Other
}

///|
/// InCB=Linker かどうか
fn is_incb_linker(cp : Int) -> Bool {
  let mut lo = 0
  let mut hi = incb_linker_table.length() - 1
  while lo <= hi {
    let mid = (lo + hi) / 2
    let v = incb_linker_table[mid]
    if cp < v {
      hi = mid - 1
    } else if cp > v {
      lo = mid + 1
    } else {
      return true
    }
  }
  false
}

///|
/// InCB=Extend かどうか
fn is_incb_extend(cp : Int) -> Bool {
  let mut lo = 0
  let mut hi = incb_extend_table.length() - 1
  while lo <= hi {
    let mid = (lo + hi) / 2
    let (start, end) = incb_extend_table[mid]
    if cp < start {
      hi = mid - 1
    } else if cp > end {
      lo = mid + 1
    } else {
      return true
    }
  }
  false
}
