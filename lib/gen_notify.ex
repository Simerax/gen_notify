defmodule GenNotify do
  @type msg :: any
  @type recipient :: atom | pid
  @callback on_message(msg) :: any

  # just a conveniece function
  def send_notification(message) do
    GenNotify.Notifier.send_notification(message)
  end

  def send_message(target, message) when is_pid(target) do
    GenServer.cast(target, {:on_message, message})
  end

  def send_message(target, message) when is_atom(target) do
    target.on_message(message)
  end


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
        GenNotify.Server.add_recipient(self())
        {:ok, nil}
      end

      def handle_cast({:on_message, message}, state) do
        on_message(message)
        {:noreply, state}
      end
    end
  end
end
