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
