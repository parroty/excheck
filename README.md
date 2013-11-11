# ExCheck [![Build Status](https://secure.travis-ci.org/parroty/excheck.png?branch=master "Build Status")](http://travis-ci.org/parroty/excheck)

Property-based testing for Elixir (QuickCheck style).
It uses Erlang's [triq](https://github.com/krestenkrab/triq) library for underlying checking engine, and ExCheck's modules provide wrapper macros for ExUnit tests.


### Usage
#### Test

```Elixir
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
```

#### Code

```Elixir
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
```

### Notes

- It's a trial implementation, and has limited functionalities yet.
- Files in test folder contains some more property examples.
