defmodule GenNotify.Application do
  use Application

  @moduledoc false

  def start(_type, _args) do
    children = [
      {GenNotify.Supervisor, []},
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
