
use "promises"
use "random"
use "files"

trait WordManager

  be initialize(path: FilePath)
  be new_word()
  be check_word(word: String, p: Promise[Bool])
  be check_letter(word: String, p: Promise[Bool])

actor FairWordManager is WordManager

  let rando: Rand = Rand
  var correct_word: String = ""
  var dict: Array[String] = []

  new create(path: FilePath) =>
    initialize(path)

  be initialize(path: FilePath) =>
    let file = File(path)
    for line in file.lines() do
      dict.push(consume line)
    end
    new_word()

  be new_word() =>
    let idx = USize.from[U64](rando.next()) % dict.size()
    correct_word = try dict(idx)? else "error" end

  be check_word(word: String, p: Promise[Bool]) =>
    p(correct_word == word)

  be check_letter(letter: String, p: Promise[Bool]) =>
    try
      correct_word.find(letter)?
      p(true)
    else
      p(false)
    end
