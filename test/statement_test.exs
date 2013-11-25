defmodule ExCheck.StatementTest do
  use ExUnit.Case, async: false
  use ExCheck

  test "verify succeeds" do
    assert verify_property(
      for_all n in int, do: is_integer(n)
    )
  end

  test "verify fails" do
    assert verify_property(
      for_all b in bool, do: is_integer(b)
    ) == false
  end
end