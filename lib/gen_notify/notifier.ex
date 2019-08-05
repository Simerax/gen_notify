defmodule GenNotify.Notifier do
  use GenServer
  @name __MODULE__

  @moduledoc """
  The `GenNotify.Notifier` is the background process of `GenNotify`.
  This Module is responsible for sending the notifications and keeps track of the recipients.


  ## Do I even need to know about this?
  
  You will not need to interact with this Module directly except for starting it via `GenNotify.Notifier.start_link/0`.
  Even this will not be needed if you use the `GenNotify.Supervisor`.

  The only exception is if you want to implement your own Module with the `GenNotify` Behaviour (not `use GenNotify`!)
  """

  @doc """
  Sends the `message` to all known recipients.
  You can also use `GenNotify.send_notification/1` as a shortcut.
  """
  @spec send_notification(any) :: :ok
  def send_notification(message) do
    GenServer.cast(@name, {:send_notification, message})
  end


  @doc """
  Adds a new `recipient` to the list of recipients.

  The list of recipients is always unique. 
  If you try to add the same `recipient` multiple times it will still only be stored once
  and therefore `GenNotify.on_message/1` will only be called once per notification per module/pid.
  """
  @spec add_recipient(pid() | atom()) :: :ok
  def add_recipient(recipient) when is_pid(recipient) do
    GenServer.call(@name, {:add_recipient, recipient})
  end

  def add_recipient(recipient) when is_atom(recipient) do
    GenServer.call(@name, {:add_recipient, recipient})
  end

  @doc """
  returns what `GenServer.start_link` does
  """
  def start_link(_), do: start_link()
  def start_link() do
    GenServer.start_link(@name, :ok, name: @name)
  end

  @impl true
  def init(_) do
    {:ok, %{recipients: []}}
  end

  @impl true
  def handle_cast({:send_notification, message}, state) do
    state |> send_notifications(message)
    {:noreply, state}
  end

  @doc false
  defp send_notifications(state, message) do
    state.recipients |> Enum.each(&(GenNotify.send_message(&1, message)))
  end

  @impl true
  def handle_call({:add_recipient, recipient}, _from, state) do
    new_state = state |> _add_recipient(recipient)
    {:reply, :ok, new_state}
  end

  @doc false
  defp _add_recipient(state, recipient) do
    recipients = [recipient | state.recipients] |> Enum.uniq 
    %{state | recipients: recipients}
  end
end
