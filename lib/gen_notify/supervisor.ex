defmodule GenNotify.Supervisor do
  use Supervisor
  @moduledoc """
  Supervisor to get the `GenNotify` Module running
  """

  @name __MODULE__

  def start_link(config \\ []) do
    Supervisor.start_link(@name, config, name: @name)
  end

  @impl true
  def init(config) do
    children = [
      {GenNotify.Notifier, [recipients: config[:recipients]]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
