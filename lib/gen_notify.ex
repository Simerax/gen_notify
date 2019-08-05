defmodule GenNotify do
  @type msg :: any
  @type recipient :: atom | pid

  @doc """
  callback which will be invoked when a notification is sent via `GenNotify.Notifier.send_notification/1`
  """
  @callback on_message(msg) :: any


  @moduledoc """
  This is the main module that you will come in contact with.

  you can `use` this module to inherit its functionality.

  ## What is GenNotify
  You can basically think of it as some kind of broadcast/multicast module.
  It's for forwarding Messages to everyone who is in the list of recipients.

  ## Example

      defmodule MyNotification do
        use GenNotify
  
        def on_message(msg) do
          IO.puts("I got a message: #\{msg}")
        end
      end

  To get up and running we do need to make sure that our Notifier is started.

      GenNotify.Notifier.start_link()

  Our Custom Notification has to be initialized at some point after `GenNotify.Notifier`.
  This will tell the Notifier to watch this Module

      MyNotification.gen_notify_init()

  somewhere else in the code...

      GenNotify.send_notification("im a message") # => This will cause MyNotification.on_message/1 to be called

  ## Example - GenServer

  Sometimes a notification for a module isn't quite what you want. You want notifications for a specific Process.
  `GenNotify` does support `GenServer`


      defmodule MyGenServer do
        use GenServer
        use GenNotify, server: true # we need to tell GenNotify that this is indeed is a server

        def start_link(_) do
          GenServer.start_link(__MODULE__, :ok)
        end

        def init(_) do
          gen_notify_init() # => This will supply our PID to GenNotify.Notifier (Keep in mind, GenNotify.Notifier already needs to be alive!)
          {:ok, %{}}
        end

        def on_message(msg) do
          IO.puts(msg) # => will be "im a message" in our example
        end
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
    case opts[:server] do
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
        on_message(message)
        {:noreply, state}
      end
    end
  end
end
