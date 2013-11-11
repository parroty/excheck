defmodule ExCheck.SampleTest do
  use ExUnit.Case, async: false
  use ExCheck
  alias ExCheck.Sample

  property :square do
    for_all(x, int) do
      x * x >= 0
    end
  end

  property :implies do
    for_all(x, int) do
      implies(x >= 0) do
        x >= 0
      end
    end
  end

  property :such_that do
    for_all({x, y}, such_that({xx, yy}, {int, int}, xx < yy)) do
      x < y
    end
  end

  property :concat_list do
    for_all({xs, ys}, {list(int), list(int)}) do
      Enum.count(Sample.concat(xs, ys)) == Enum.count(xs) + Enum.count(ys)
    end
  end

  property :push_list do
    for_all({x, y}, {int, list(int)}) do
      result = Sample.push(x, y)
      Enum.first(result) == x and Enum.count(result) == Enum.count(y) + 1
    end
  end
end
