
use "files"
use "promises"
use "term"

class HangmanState
  var guessed_letters: Array[String] = []
  var wrong_letters: Array[String] = []
  var hangman_count: U8 = 0
  new ref create() => None
  fun ref add_to_count() =>
    hangman_count = hangman_count + 1
  fun ref add_guessed(s: String) =>
    guessed_letters.push(s)
  fun ref add_wrong(s: String) =>
    wrong_letters.push(s)
  fun get_guesses_clone(wrong: Bool = false): Array[String]val =>
    let arr = if wrong then wrong_letters else guessed_letters end

    let length = arr.size()
    let guessed_clone = recover Array[String](length) end
    for guess in arr.values() do
      guessed_clone.push(guess)
    end
    consume guessed_clone


actor Main

  let hangman_state: HangmanState ref

  new create(env': Env) =>

    hangman_state       = HangmanState

    let display_factory = ConsoleDisplay(env')
    let input_factory   = ConsoleInput(env')
    let word_factory    = try FairWordManager(
          FilePath(env'.root as AmbientAuth, "english-words.txt")?
      )
    else
      env'.out.print("Error during init")
      return
    end

    let key_pressed = Promise[String]
    .> next[None](recover this~handle_input(
        display_factory, input_factory, word_factory
      ) end)
    input_factory.notify_on_next_key(key_pressed)

    setup_display(word_factory, display_factory)

  be handle_input(display_factory: Display tag,
  input_factory: Input tag,
  word_factory: WordManager tag,
  inp: String) =>

    word_factory.check_letter(inp, Promise[Bool]
    .> next[None](recover this~handle_letter_check(
        display_factory, word_factory, inp
      ) end))

    input_factory.notify_on_next_key(Promise[String]
    .> next[None](recover this~handle_input(
      display_factory, input_factory, word_factory
    ) end))

  be handle_letter_check(display_factory: Display tag,
  word_factory: WordManager tag,
  letter: String,
  res: Bool) =>
    if res then
      hangman_state.add_guessed(letter)
    else
      hangman_state.add_wrong(letter)
      hangman_state.add_to_count()
    end

    setup_display(word_factory, display_factory)

  be setup_display(word_factory: WordManager tag,
  display_factory: Display tag) =>
    // capture relevant variable
    let stage = hangman_state.hangman_count
    let right_guesses_cloned = hangman_state.get_guesses_clone(
      where wrong=false)
    let wrong_guesses_cloned = hangman_state.get_guesses_clone(
      where wrong=true)

    word_factory.make_masked(
    right_guesses_cloned,
    Promise[String]
    .> next[None]({
      (masked_word: String)(display_factory, stage, wrong_guesses_cloned) =>
        display_factory.display_all(
          masked_word, wrong_guesses_cloned, stage
        )
    }))
