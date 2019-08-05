defmodule GenNotify do
  @type msg :: any
  @type state :: any
  @type recipient :: atom | pid

  @doc """
  callback which will be invoked when a notification is sent via `GenNotify.Notifier.send_notification/1`
  In case you `use GenNotify, gen_server: true` then `on_message/2` will be called.
  """
  @callback on_message(msg) :: any
  @callback on_message(msg, state) :: state


  @moduledoc """
  This is the main module that you will come in contact with.

  you can `use` this module to inherit its functionality.

  ## What is GenNotify
  You can basically think of it as some kind of broadcast/multicast module.
  It's for forwarding Messages to everyone who is in the list of recipients.

  ## Example

      defmodule MyNotification do
        use GenNotify
  
        def on_message(msg) when is_binary(msg) do
          IO.puts("I got a message: #\{msg}")
        end

        # we ignore all other kinds of messages
        def on_message(_msg), do: nil
      end

  To get up and running we need to make sure that our Notification Service is started.

      # lets add our Custom Notification to the list of recipients
      config = [
        recipients: [
          MyNotification
        ]
      ]
      GenNotify.Supervisor.start_link(config)


  If you dont want a Notification to be added to the recipients right away you can start the Service without any recipients and add them later by hand
      GenNotify.Supervisor.start_link()
      MyNotification.gen_notify_init()



  somewhere else in the code...

      GenNotify.send_notification("im a message") # => This will cause MyNotification.on_message/1 to be called

  ## Example - GenServer

  Sometimes a notification for a module isn't quite what you want. You want notifications for a specific Process.
  `GenNotify` does support `GenServer`


      defmodule MyGenServer do
        use GenServer
        use GenNotify, gen_server: true # we need to tell GenNotify that this is indeed is a GenServer

        def start_link(_) do
          GenServer.start_link(__MODULE__, :ok)
        end

        def init(_) do
          gen_notify_init() # => This will supply our PID to GenNotify.Notifier (Keep in mind, GenNotify.Supervisor already needs to be alive!)
          {:ok, %{messages: 0}}
        end

        def on_message(msg, state) when is_binary(msg) do
          new_state = %{state | messages: state.messages + 1}
          IO.puts("#\{msg} is my #\{new_state.messages} message!") # => will be "im a message is my X message!" in our example

          # Give the updated state back to the GenServer
          new_state 
        end

        # we ignore all other kinds of messages
        def on_message(_msg, state), do: state
      end
  
  somewhere else in the code...

      GenNotify.send_notification("im a message")
      
  """

  @doc """
  delegation to `GenNotify.Notifier.send_notification/1`
  """
  defdelegate send_notification(message), to: GenNotify.Notifier

  @doc false
  def send_message(target, message) when is_pid(target) do
    GenServer.cast(target, {:gen_notify_on_message, message})
  end

  @doc false
  def send_message(target, message) when is_atom(target) do
    spawn( fn -> target.on_message(message) end )
  end


  @doc false
  defmacro __using__(opts) do
    case opts[:gen_server] do
      true -> make_server()
      _ ->  make_default()
    end
  end

  defp make_default() do
    quote do
      def gen_notify_init() do
        GenNotify.Notifier.add_recipient(__MODULE__)
      end
    end
  end

  defp make_server() do
    quote do

      def gen_notify_init() do
        GenNotify.Notifier.add_recipient(self())
        {:ok, nil}
      end

      def handle_cast({:gen_notify_on_message, message}, state) do
        new_state = on_message(message, state)
        {:noreply, new_state}
      end
    end
  end
end
