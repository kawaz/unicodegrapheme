///|
test "bench: graphemes ASCII short" (b : @bench.T) {
  let s = "Hello, World!"
  b.bench(fn() {
    let g = graphemes(s)
    b.keep(g)
  })
}

///|
test "bench: graphemes ASCII long" (b : @bench.T) {
  // Pre-build a 1000-character ASCII string
  let buf = StringBuilder::new()
  for i = 0; i < 100; i = i + 1 {
    buf.write_string("0123456789")
  }
  let s = buf.to_string()
  b.bench(fn() {
    let g = graphemes(s)
    b.keep(g)
  })
}

///|
test "bench: graphemes emoji ZWJ" (b : @bench.T) {
  // Family emoji x 10
  let buf = StringBuilder::new()
  for i = 0; i < 10; i = i + 1 {
    buf.write_string(
      "\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}\u{200D}\u{1F466}",
    )
  }
  let s = buf.to_string()
  b.bench(fn() {
    let g = graphemes(s)
    b.keep(g)
  })
}

///|
test "bench: graphemes flags" (b : @bench.T) {
  // Flags x 10
  let buf = StringBuilder::new()
  for i = 0; i < 10; i = i + 1 {
    buf.write_string("\u{1F1EF}\u{1F1F5}")
  }
  let s = buf.to_string()
  b.bench(fn() {
    let g = graphemes(s)
    b.keep(g)
  })
}

///|
test "bench: graphemes hangul" (b : @bench.T) {
  // Hangul string
  let s = "안녕하세요 세계 여러분"
  b.bench(fn() {
    let g = graphemes(s)
    b.keep(g)
  })
}

///|
test "bench: graphemes devanagari" (b : @bench.T) {
  // Devanagari (activates InCB state)
  let s = "\u{0915}\u{094D}\u{0915}\u{093E}\u{0915}\u{094D}\u{0915}\u{093E}\u{0915}\u{094D}\u{0915}\u{093E}"
  b.bench(fn() {
    let g = graphemes(s)
    b.keep(g)
  })
}

///|
test "bench: graphemes mixed real world" (b : @bench.T) {
  // Mixed real-world text
  let s = "Hello🌍, こんにちは世界! 🇯🇵🇺🇸 가나다라 👨\u{200D}👩\u{200D}👧\u{200D}👦"
  b.bench(fn() {
    let g = graphemes(s)
    b.keep(g)
  })
}

///|
test "bench: graphemes slice" (b : @bench.T) {
  let g = graphemes("Hello, World! This is a test string for slicing.")
  b.bench(fn() {
    let sliced = g[5:10]
    b.keep(sliced)
  })
}

///|
test "bench: gcb_category ASCII" (b : @bench.T) {
  b.bench(fn() {
    let cat = gcb_category(0x41) // 'A'
    b.keep(cat)
  })
}

///|
test "bench: gcb_category emoji" (b : @bench.T) {
  b.bench(fn() {
    let cat = gcb_category(0x1F600) // grinning face
    b.keep(cat)
  })
}

///|
test "bench: grapheme_iter ASCII long (first 10 only)" (b : @bench.T) {
  let buf = StringBuilder::new()
  for i = 0; i < 100; i = i + 1 {
    buf.write_string("0123456789")
  }
  let s = buf.to_string()
  b.bench(fn() {
    let mut count = 0
    for _cluster in grapheme_iter(s) {
      count += 1
      if count >= 10 { break }
    }
    b.keep(count)
  })
}

///|
test "bench: graphemes ASCII long (first 10 via slice)" (b : @bench.T) {
  let buf = StringBuilder::new()
  for i = 0; i < 100; i = i + 1 {
    buf.write_string("0123456789")
  }
  let s = buf.to_string()
  b.bench(fn() {
    let g = graphemes(s)
    let sliced = g[0:10]
    b.keep(sliced)
  })
}
