defmodule GenNotify.Supervisor.Test do
  use ExUnit.Case, async: true

  test "supervisor starts with its children as expected" do
    GenNotify.Supervisor.start_link()

    # the supervisor should have started our Notifier
    assert GenNotify.Notifier.send_notification("test") == :ok
  end
end
