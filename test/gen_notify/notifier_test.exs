defmodule GenNotify.Notifier.Test do
  use ExUnit.Case

  import Mox

  test "Notifies a children" do
    GenNotify.Notifier.start_link()

    GenNotify.Mock
    |> expect(:on_message, fn msg ->
      assert msg == "Test"
    end)

    assert GenNotify.Notifier.add_recipient(GenNotify.Mock) == :ok
    assert GenNotify.Notifier.send_notification("Test") == :ok
  end
end
