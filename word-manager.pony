
use "promises"
use "random"
use "files"
use "time"

trait WordManager

  be initialize(path: FilePath)
  be new_word()
  be check_word(word: String, p: Promise[Bool])
  be check_letter(word: String, p: Promise[Bool])
  be make_masked(letters: Array[String]val, p: Promise[String])

actor FairWordManager is WordManager

  let rando: Rand
  var correct_word: String = ""
  var dict: Array[String] = []

  new create(path: FilePath) =>
    rando = Rand(Time.nanos(), Time.millis())
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
    p(correct_word.contains(letter))

  fun guessed(chr: String, guesses: Array[String]val): Bool =>
    for guess in guesses.values() do
      if chr == guess then return true end
    end
    false

  //TODO refactor this
  be make_masked(guesses: Array[String]val, p: Promise[String]) =>
    let out = recover
      let s = String(correct_word.size())
      for char in correct_word.values() do
        let str = String.from_array([char])
        s.append(if guessed(str, guesses)
        then str
        else "_" end)
      end
      s
    end
    p(consume out)
