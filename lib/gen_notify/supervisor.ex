defmodule GenNotify.Supervisor do
  use Supervisor
  @moduledoc """
  Supervisor to get the `GenNotify` Module running
  """

  @name __MODULE__

  def start_link(arg \\ nil) do
    Supervisor.start_link(@name, arg, name: @name)
  end

  @impl true
  def init(_arg) do
    children = [
      {GenNotify.Notifier, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
