defmodule GenNotify.Notifier do
  use GenServer
  @name __MODULE__

  @moduledoc """
  Documentation for GenNotify.
  """

  @doc """
  Hello world.

  ## Examples

      iex> GenNotify.hello()
      :world

  """

  # Client API
  def send_notification(message) do
    GenServer.cast(@name, {:send_notification, message})
  end

  def add_recipient(recipient) when is_pid(recipient) do
    GenServer.call(@name, {:add_recipient, recipient})
  end

  def add_recipient(recipient) when is_atom(recipient) do
    GenServer.call(@name, {:add_recipient, recipient})
  end

  def start_link() do
    GenServer.start_link(@name, :ok, name: @name)
  end

  def init(_) do
    {:ok, %{recipients: []}}
  end

  def handle_cast({:send_notification, message}, state) do
    state |> send_notifications(message)
    {:noreply, state}
  end

  defp send_notifications(state, message) do
    state.recipients |> Enum.each(&(GenNotify.send_message(&1, message)))
  end

  def handle_call({:add_recipient, recipient}, _from, state) do
    new_state = %{state | recipients: [recipient | state.recipients]}
    {:reply, :ok, new_state}
  end
end
