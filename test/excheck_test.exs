defmodule ExCheckTest do
  use ExUnit.Case, async: false
  use ExCheck

  property :reverse do
    for_all({xs, ys}, {list(int), list(int)}) do
      Enum.reverse(Enum.concat(xs, ys)) ==
        Enum.concat(Enum.reverse(ys), Enum.reverse(xs))
    end
  end

  property :list_counts do
    for_all(xs, list(int)) do
      Enum.count(xs) >= 0
    end
  end

  property :square do
    for_all(x, int) do
      x * x >= 0
    end
  end

  # generators
  property :boolean do
    for_all(b, bool) do is_boolean(b) end
  end
  property :atom do
    for_all(a, atom) do is_atom(a) end
  end
  property :binary do
    for_all(b, binary) do is_binary(b) end
  end
  property :real do
    for_all(r, real) do is_float(r) end
  end
  property :byte do
    for_all(b, byte) do is_integer(b) end
  end
  property :tuple do
    for_all(t, tuple(int)) do is_tuple(t) end
  end
  property :char do
    for_all(c, char) do is_integer(c) end
  end
  property :unicode_char do
    for_all(c, unicode_char) do is_integer(c) end
  end
  property :oneof do
    for_all(v, oneof([1, 2])) do
      v == 1 or v == 2
    end
  end
  property :frequency do
    for_all(v, frequency([{10, :a}, {1, :b}])) do
      v == :a or v == :b
    end
  end
  property :pos_integer do
    for_all(v, pos_integer) do v > 0 end
  end

  test :sample_boolean do
    Enum.each(sample(bool), &(assert is_boolean(&1)))
  end

  test :sample_integer do
    Enum.each(sample(int), &(assert is_integer(&1)))
  end

  test :pick_integer do
    {_, value} = pick(int, 1)
    assert value >= -5 and value <= 5
  end
end
