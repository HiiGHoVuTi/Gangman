
trait Display

  be display_all(masked_word: String,
    wrong_guesses: Array[String]val,
    stage: U8)
  fun display_word(word: String)
  fun display_hangman(stage: U8)

actor ConsoleDisplay is Display

  let env: Env

  new create(env': Env) =>
    env = env'

  be display_all(masked_word: String,
  wrong_guesses: Array[String]val,
  stage: U8) =>
    env.out.print("\n\n")
    display_hangman(stage)
    display_word(masked_word)
    display_wrong_guesses(wrong_guesses)
    env.out.write("> ")

  fun display_word(word: String) =>
    env.out.print(word)

  fun display_hangman(stage: U8) =>
    env.out.print("At stage: " + stage.string())

  fun display_wrong_guesses(guesses: Array[String]val) =>
    env.out.print("Wrong guesses: " + " - ".join(guesses.values()))
