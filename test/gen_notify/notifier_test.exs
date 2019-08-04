defmodule GenNotify.Notifier.Test do
  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!
  setup :set_mox_global

  setup do
    GenNotify.Notifier.start_link()
    :ok
  end

  test "Notifies a children" do

    GenNotify.Mock
    |> expect(:on_message, fn msg -> assert msg == "Test" end)

    assert GenNotify.Notifier.add_recipient(GenNotify.Mock) == :ok
    assert GenNotify.Notifier.send_notification("Test") == :ok

    Process.sleep(100)

  end
end
