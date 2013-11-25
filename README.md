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
    for_all x in int, do: x * x >= 0
  end

  property :implies do
    for_all x in int do
      implies x >= 0 do
        x >= 0
      end
    end
  end

  property :such_that do
    for_all {x, y} in such_that({xx, yy} in {int, int} when xx < yy) do
      x < y
    end
  end

  property :concat_list do
    for_all {xs, ys} in {list(int), list(int)} do
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

#### Run

```Shell
$ mix test test/sample_test.exs
....................................................................................................
Ran 100 tests
....x.....xx.x.xxxx.xxxx...xxxx...xx.xxxx...x.....x.x.xx...xx.x...xxx..x...xx..xxxxx..xxxx...x.x.xxx.
Ran 50 tests
.....................................................................................................
Ran 100 tests
.....................................................................................................
Ran 100 tests
.....................................................................................................
Ran 100 tests
.

Finished in 0.2 seconds (0.1s on load, 0.03s on tests)
5 tests, 0 failures
```

### Generators
The following generators defined in :triq are imported through "use ExCheck" statement.

- list/1, tuple/1, int/0, int/1, int/2, byte/0, real/0, sized/1, elements/1, any/0, atom/0, atom/1, choose/2, oneof/1, frequency/1, bool/0, char/0, return/1, vector/2, binary/1, binary/0, non_empty/1, resize/2, non_neg_integer/0, pos_integer/0,
- unicode_char/0, unicode_string/0, unicode_string/1, unicode_binary/0, unicode_binary/1, unicode_binary/2, unicode_characters/0, unicode_characters/1,
- bind/2, bindshrink/2, suchthat/2, pick/2, shrink/2, sample/1, sampleshrink/1, seal/1, open/1, peek/1, domain/3, shrink_without_duplicates/1


### Notes

- It's a trial implementation, and has limited functionalities yet.
- Files in test folder contains some more property examples.
