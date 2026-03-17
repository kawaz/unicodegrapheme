///|
test "graphemes: ASCII 文字列" {
  let g = graphemes("hello")
  inspect(g.length(), content="5")
}

///|
test "graphemes: BMP 文字" {
  let g = graphemes("あいう")
  inspect(g.length(), content="3")
}

///|
test "graphemes: サロゲートペア文字" {
  let g = graphemes("A\u{1F600}B")
  inspect(g.length(), content="3")
  inspect(g[1].to_string(), content="\u{1F600}")
}

///|
test "graphemes: iter" {
  let result : Array[String] = []
  for cluster in graphemes("A\u{1F600}B").iter() {
    result.push(cluster.to_string())
  }
  inspect(result, content=(
    #|["A", "😀", "B"]
  ))
}

///|
test "graphemes: 空文字列" {
  let g = graphemes("")
  inspect(g.length(), content="0")
}

///|
// 結合文字: 「か」(U+304B) + 結合濁点(U+3099) → 1 cluster
test "graphemes: 結合文字 が" {
  let g = graphemes("\u{304B}\u{3099}")
  inspect(g.length(), content="1")
  inspect(g[0].to_string(), content="\u{304B}\u{3099}")
}

///|
// CRLF: \r\n → 1 cluster
test "graphemes: CRLF" {
  let g = graphemes("\r\n")
  inspect(g.length(), content="1")
}

///|
// Control 前後: NUL + A → 2 clusters
test "graphemes: Control 前後" {
  let g = graphemes("\u{0000}A")
  inspect(g.length(), content="2")
}

///|
// SpacingMark: デーヴァナーガリー "का" (U+0915 U+093E) → 1 cluster
test "graphemes: SpacingMark デーヴァナーガリー" {
  let g = graphemes("\u{0915}\u{093E}")
  inspect(g.length(), content="1")
}

///|
// 国旗: 🇯🇵 (RI+RI) → 1 cluster
test "graphemes: 国旗 🇯🇵" {
  let g = graphemes("\u{1F1EF}\u{1F1F5}")
  inspect(g.length(), content="1")
}

///|
// 国旗2つ: 🇯🇵🇺🇸 (RI RI RI RI) → 2 clusters
test "graphemes: 国旗2つ 🇯🇵🇺🇸" {
  let g = graphemes("\u{1F1EF}\u{1F1F5}\u{1F1FA}\u{1F1F8}")
  inspect(g.length(), content="2")
}

///|
// 絵文字 ZWJ シーケンス: 👨‍👩‍👧‍👦 → 1 cluster
test "graphemes: 家族絵文字 ZWJ" {
  // 👨 U+1F468, ZWJ U+200D, 👩 U+1F469, ZWJ, 👧 U+1F467, ZWJ, 👦 U+1F466
  let g = graphemes(
    "\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}\u{200D}\u{1F466}",
  )
  inspect(g.length(), content="1")
}

///|
// InCB Conjunct: デーヴァナーガリー क + ् + क (Consonant + Virama + Consonant) → 1 cluster
test "graphemes: InCB Conjunct" {
  // क U+0915 (InCB_Consonant), ् U+094D (Virama = InCB Linker + Extend), क U+0915
  let g = graphemes("\u{0915}\u{094D}\u{0915}")
  inspect(g.length(), content="1")
}

///|
// RI 3個: 🇯🇵 + 孤立 RI → 2 clusters ([RI RI] [RI])
test "graphemes: RI x3" {
  let g = graphemes("\u{1F1EF}\u{1F1F5}\u{1F1FA}")
  inspect(g.length(), content="2")
}

///|
// RI 5個: 🇯🇵🇺🇸 + 孤立 RI → 3 clusters ([RI RI] [RI RI] [RI])
test "graphemes: RI x5" {
  let g = graphemes("\u{1F1EF}\u{1F1F5}\u{1F1FA}\u{1F1F8}\u{1F1E6}")
  inspect(g.length(), content="3")
}

// ============================================================
// A. op_get 境界値テスト
// ============================================================

///|
test "graphemes: op_get first index" {
  let g = graphemes("ABC")
  inspect(g[0].to_string(), content="A")
}

///|
test "graphemes: op_get last index" {
  let g = graphemes("ABC")
  inspect(g[g.length() - 1].to_string(), content="C")
}

// ============================================================
// B. パニックテスト — op_get の範囲外アクセス
// ============================================================

///|
// 負のインデックスでパニック
test "panic op_get negative index" {
  let g = graphemes("ABC")
  let _ = g[-1]

}

///|
// length() 以上のインデックスでパニック
test "panic op_get out of range" {
  let g = graphemes("ABC")
  let _ = g[3]

}

///|
// 空文字列に対する op_get でパニック
test "panic op_get on empty" {
  let g = graphemes("")
  let _ = g[0]

}

// ============================================================
// C. length() の各種ケーステスト
// ============================================================

///|
test "graphemes: length of single ASCII char" {
  inspect(graphemes("A").length(), content="1")
}

///|
test "graphemes: length of single emoji" {
  inspect(graphemes("\u{1F600}").length(), content="1")
}

///|
test "graphemes: length of single flag" {
  inspect(graphemes("\u{1F1EF}\u{1F1F5}").length(), content="1")
}

///|
test "graphemes: length of family emoji" {
  inspect(
    graphemes("\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}\u{200D}\u{1F466}").length(),
    content="1",
  )
}

// ============================================================
// D. iter() の各種ケーステスト
// ============================================================

///|
test "graphemes: iter empty produces no elements" {
  let g = graphemes("")
  let mut count = 0
  for _cluster in g.iter() {
    count += 1
  }
  inspect(count, content="0")
}

///|
test "graphemes: iter collects all clusters" {
  let g = graphemes("A\u{1F600}B")
  let collected : Array[String] = []
  for cluster in g.iter() {
    collected.push(cluster.to_string())
  }
  inspect(collected.length(), content="3")
  inspect(collected[0], content="A")
  inspect(collected[1], content="\u{1F600}")
  inspect(collected[2], content="B")
}

// ============================================================
// E. 特殊文字列テスト
// ============================================================

///|
// ZWJ 単体は 1 クラスタ
test "graphemes: lone ZWJ" {
  inspect(graphemes("\u{200D}").length(), content="1")
}

///|
// 非常に長い ASCII 文字列
test "graphemes: long ASCII string" {
  let buf = StringBuilder::new()
  for _i = 0; _i < 1000; _i = _i + 1 {
    buf.write_char('A')
  }
  let s = buf.to_string()
  inspect(graphemes(s).length(), content="1000")
}

///|
// 結合文字の連鎖: 'a' + 10個の combining acute accent (U+0301) = 1 cluster
test "graphemes: many combining marks" {
  let buf = StringBuilder::new()
  buf.write_char('a')
  for _i = 0; _i < 10; _i = _i + 1 {
    buf.write_char('\u{0301}')
  }
  let s = buf.to_string()
  inspect(graphemes(s).length(), content="1")
}

///|
// CRLF 混在: \r\n(1) + \n(1) + \r(1) = 3 clusters
test "graphemes: mixed newlines" {
  let g = graphemes("\r\n\n\r")
  inspect(g.length(), content="3")
}

///|
// 単独 CR は 1 cluster
test "graphemes: lone CR" {
  inspect(graphemes("\r").length(), content="1")
}

///|
// 単独 LF は 1 cluster
test "graphemes: lone LF" {
  inspect(graphemes("\n").length(), content="1")
}

///|
// Extend のみ（base 文字なし）は 1 cluster
test "graphemes: lone combining mark" {
  inspect(graphemes("\u{0301}").length(), content="1")
}

///|
// keycap sequence: digit + U+FE0F + U+20E3 = 1 cluster
test "graphemes: keycap sequence" {
  let g = graphemes("1\u{FE0F}\u{20E3}")
  inspect(g.length(), content="1")
}

///|
// emoji modifier sequence: 👋 + skin tone modifier = 1 cluster
test "graphemes: emoji modifier sequence" {
  let g = graphemes("\u{1F44B}\u{1F3FD}")
  inspect(g.length(), content="1")
}

// ============================================================
// F. graphemes() の不変条件テスト — 全クラスタ連結 == 元文字列
// ============================================================

///|
test "graphemes: concatenation invariant ASCII" {
  let input = "Hello World"
  let g = graphemes(input)
  let buf = StringBuilder::new()
  for cluster in g.iter() {
    buf.write_string(cluster.to_string())
  }
  inspect(buf.to_string(), content="Hello World")
}

///|
test "graphemes: concatenation invariant mixed" {
  let input = "Hello\u{1F1EF}\u{1F1F5}World\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}\u{200D}\u{1F466}!"
  let g = graphemes(input)
  let buf = StringBuilder::new()
  for cluster in g.iter() {
    buf.write_string(cluster.to_string())
  }
  inspect(buf.to_string() == input, content="true")
}

///|
test "graphemes: concatenation invariant empty" {
  let input = ""
  let g = graphemes(input)
  let buf = StringBuilder::new()
  for cluster in g.iter() {
    buf.write_string(cluster.to_string())
  }
  inspect(buf.to_string(), content="")
}

///|
test "graphemes: concatenation invariant combining marks" {
  // 'a' + combining acute accent + combining grave accent
  let input = "a\u{0301}\u{0300}"
  let g = graphemes(input)
  let buf = StringBuilder::new()
  for cluster in g.iter() {
    buf.write_string(cluster.to_string())
  }
  inspect(buf.to_string() == input, content="true")
}

///|
// length() と iter() のカウントは一致するべき
test "graphemes: length equals iter count" {
  let inputs = [
    "", "A", "ABC", "\u{1F600}", "\r\n",
    "\u{1F1EF}\u{1F1F5}", "\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}\u{200D}\u{1F466}",
    "a\u{0301}\u{0302}\u{0303}",
  ]
  for input in inputs {
    let g = graphemes(input)
    let mut count = 0
    for _cluster in g.iter() {
      count += 1
    }
    assert_eq(g.length(), count)
  }
}
