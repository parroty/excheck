defmodule ExCheck.SampleTest do
  use ExUnit.Case, async: false
  use ExCheck

  test "verify sample property" do
    assert ExCheck.check(ExCheck.Sample)
  end
end
