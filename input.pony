
use "promises"
use "term"


trait Input
  be notify_on_next_key(p: Promise[String])


class ConsoleHandler is ReadlineNotify
  let act: ConsoleInput
  new create(act': ConsoleInput) => act = act'
  fun ref apply(line: String, prompt: Promise[String]) =>
    act.react(line, prompt)

actor ConsoleInput is Input

  let message: String = ""
  var current_promise: (None | Promise[String])

  new create(env': Env) =>
    current_promise = None
    let term = ANSITerm(Readline(recover ConsoleHandler(this) end, env'.out), env'.input)
    term.prompt(message)
    let notify = object iso
      let term: ANSITerm = term
      fun ref apply(data: Array[U8] iso) => term(consume data)
      fun ref dispose() => term.dispose()
    end

    env'.input(consume notify)


  be notify_on_next_key(p: Promise[String]) =>
    current_promise = p

  be react(line: String, prompt: Promise[String]) =>
    if line == "quit" then
      prompt.reject()
    end

    match current_promise
    | let p: Promise[String] =>
      p(line)
      current_promise = None
    | None => prompt(message) // throws the input away
    end

    prompt(message)
