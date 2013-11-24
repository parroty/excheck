defmodule ExCheck.StatementTest do
  use ExUnit.Case, async: false
  use ExCheck

  test "verify succeeds" do
    assert verify_property(
      for_all(n, int) do is_integer(n) end
    )
  end

  test "verify fails" do
    assert verify_property(
      for_all(b, bool) do is_integer(b) end
    ) == false
  end
end