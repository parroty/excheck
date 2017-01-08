defmodule ExCheck.Sample do
  @moduledoc """
  Sample logic to be tested by ExCheck (refer to sample_test.exs for tests).
  """
  use ExCheck

  @doc "concatinate the list."
  def concat(x, y) do
    x ++ y
  end

  @doc "push element in the list."
  def push(x, y) do
    [x|y]
  end


  @doc false
  def prop_concat_list do
    for_all({xs, ys}, {list(int()), list(int())}) do
      Enum.count(concat(xs, ys)) == Enum.count(xs) + Enum.count(ys)
    end
  end

  @doc false
  def prop_push_list do
    for_all({x, y}, {int(), list(int())}) do
      result = push(x, y)
      Enum.at(result, 0) == x and Enum.count(result) == Enum.count(y) + 1
    end
  end
end
