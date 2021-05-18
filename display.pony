
trait Display

  be display_word(word: String)
  be display_hangman(stage: U8)

actor ConsoleDisplay is Display

  let env: Env

  new create(env': Env) =>
    env = env'

  be display_word(word: String) =>
    env.out.print(word)

  be display_hangman(stage: U8) =>
    env.out.print(stage.string())
