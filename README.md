# GenNotify

## What is GenNotify

You can basically think of it as some kind of broadcast/multicast module.
It's for forwarding Messages to everyone who is in the list of recipients.
[docs](https://hexdocs.pm/gen_notify/GenNotify.html#content)


## Installation

```elixir
def deps do
  [
    {:gen_notify, "~> 0.4.0"}
  ]
end
```

```elixir

defmodule MyNotification do
  use GenNotify

  def on_message(msg) do
    IO.puts("Got the message: #{msg}")
  end
end

# add Module to recipients
MyNotification.gen_notify_init()

# send a notification
GenNotify.send_notification("I'm a message") # => will call MyNotification.on_message/1

```


