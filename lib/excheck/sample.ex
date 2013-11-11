defmodule ExCheck.Sample do
  @moduledoc """
  Sample logic to be tested by ExCheck (refer to sample_test.exs for tests)
  """

  @doc "concatinate the list"
  def concat(x, y) do
    x ++ y
  end

  @doc "push element in the list"
  def push(x, y) do
    [x|y]
  end
end
