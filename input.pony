
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

  var current_promise: (None | Promise[String])

  new create() =>
    current_promise = None

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
    | None => None // throws the input away
    end

    prompt("Input > ")
