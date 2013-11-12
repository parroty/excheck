defmodule ExCheck.SampleTest do
  use ExUnit.Case, async: false
  use ExCheck

  test "verify sample property" do
    assert ExCheck.Statement.check(ExCheck.Sample)
  end
end
