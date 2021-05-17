
use "files"
use "promises"
use "term"


class HangmanState
  var guessed_letters: Array[String] = []
  var wrong_letters: Array[String] = []
  var hangman_count: U8 = 0
  new ref create() => None
  fun ref add_guessed(s: String) =>
    guessed_letters.push(s)

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
    .> next[None](recover this~handle(
        display_factory, input_factory, word_factory
      ) end)
    input_factory.notify_on_next_key(key_pressed)

  be handle(display_factory: Display tag,
  input_factory: Input tag,
  word_factory: WordManager tag,
  inp: String) =>

    // add input verifications and dispatch from the word-manager

    //display.factory.clear() will those arrive in order doe
    //display_factory.display_hangman()
    display_factory.display_word(inp, [])

    hangman_state.add_guessed(inp)

    input_factory.notify_on_next_key(Promise[String]
    .> next[None](recover this~handle(
      display_factory, input_factory, word_factory
    ) end))
