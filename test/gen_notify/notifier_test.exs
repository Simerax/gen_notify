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

    # We sleep to make sure that the Notifier has enough time to call the on_message/1 function
    # otherwise mox will think we failed a test because :on_message wasn't called
    Process.sleep(100)
  end
end
