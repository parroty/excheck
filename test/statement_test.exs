defmodule ExCheck.StatementTest do
  use ExUnit.Case, async: false
  use ExCheck

  setup do
    {:ok, [min: 10000, max: 20000]}
  end

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

  property "verify with context", %{min: min, max: max} do
    for_all v in int(min, max), do: v >= min and v <= max
  end
end
