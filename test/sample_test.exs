defmodule ExCheck.SampleTest do
  use ExUnit.Case, async: false
  use ExCheck

  test "verify sample property" do
    assert ExCheck.check(ExCheck.Sample)
  end

  test "verify sample property with iteration parameter" do
    assert ExCheck.check(ExCheck.Sample, 10)
  end
end
