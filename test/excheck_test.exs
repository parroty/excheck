defmodule ExCheckTest do
  use ExUnit.Case, async: false
  use ExCheck

  property :reverse do
    for_all {xs, ys} in {list(int), list(int)} do
      Enum.reverse(Enum.concat(xs, ys)) ==
        Enum.concat(Enum.reverse(ys), Enum.reverse(xs))
    end
  end

  property :list_counts do
    for_all xs in list(int), do: Enum.count(xs) >= 0
  end

  property :square do
    for_all x in int, do: x * x >= 0
  end

  # specify iteration count for running test
  @tag iterations: 30
  property :square_with_iteration_parameter do
    for_all x in int, do: x * x >= 0
  end

  # generators
  property :boolean do
    for_all b in bool, do: is_boolean(b)
  end
  property :atom do
    for_all a in atom, do: is_atom(a)
  end
  property :binary do
    for_all b in binary, do: is_binary(b)
  end
  property :real do
    for_all r in real, do: is_float(r)
  end
  property :byte do
    for_all b in byte, do: is_integer(b)
  end
  property :tuple do
    for_all t in tuple(int), do: is_tuple(t)
  end
  property :char do
    for_all c in char, do: is_integer(c)
  end
  property :unicode_char do
    for_all u in unicode_char, do: is_integer(u)
  end
  property :oneof do
    for_all v in oneof([1, 2]), do: v == 1 or v == 2
  end
  property :frequency do
    for_all v in frequency([{10, :a}, {1, :b}]) do
      v == :a or v == :b
    end
  end
  property :pos_integer do
    for_all v in pos_integer, do: v > 0
  end
  property :integer_min_max do
    for_all v in int(10000, 20000), do: v >= 10000 and v <= 20000
  end

  property :float_min_max do
    for_all int_value in int(10001, 20000) do
      float_value = int_value / 10000
      Float.ceil(float_value) == 2
    end
  end

  property :number do
    for_all v in number, do: is_integer(v) or is_float(v)
  end

  test :sample_boolean do
    Enum.each(sample(bool), &(assert is_boolean(&1)))
  end

  test :sample_integer do
    Enum.each(sample(int), &(assert is_integer(&1)))
  end

  test :pick_integer do
    {_, value} = pick(int, 10)
    assert value >= -5 and value <= 5
  end

  test :pick_tuple do
    {_, {v1, v2}} = pick({int, int}, 10)
    assert is_integer(v1) and is_integer(v2)
  end

end
