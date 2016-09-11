# ExCheck [![Build Status](https://secure.travis-ci.org/parroty/excheck.png?branch=master "Build Status")](http://travis-ci.org/parroty/excheck) [![Coverage Status](http://img.shields.io/coveralls/parroty/excheck.svg)](https://coveralls.io/r/parroty/excheck) [![Inline docs](http://inch-ci.org/github/parroty/excheck.svg?branch=master&style=flat)](http://inch-ci.org/github/parroty/excheck)

Property-based testing for Elixir (QuickCheck style).
It uses Erlang's [triq](https://github.com/krestenkrab/triq) library for underlying checking engine, and ExCheck's modules provide wrapper macros for ExUnit tests.

Note: as of v0.5, `triqng/triq` is applied for fixing the issue #30.

### Installation

First add ExCheck and triq to your project's dependencies in mix.exs.

```Elixir
  defp deps do
    [
      {:excheck, "~> 0.5", only: :test},
      {:triq, github: "triqng/triq", only: :test}
    ]
  end
```
You need to have erlang-eunit installed in order to build triq.

and add the following to test_helper.exs:

```Elixir
ExCheck.start
# ... other helper functions
ExUnit.start
```

### Configuration
You can also specify the amount of tests that you want to run for each property
by adding the following to your config.exs:

```Elixir
use Mix.Config
# import "#{Mix.env}.exs"  # If you want to specify different amount for each environment

# And then in this file (or different amount in each config file):
config :excheck, :number_iterations, 200
```
**Note:** This setting is not effective for `ExCheck.check(module_name)` at the moment (refer to [#13](https://github.com/parroty/excheck/pull/13)).

### Usage
The following is an testing example. `ExCheck.SampleTest` is the testing code for `ExCheck.Sample`.

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
      #implies skip samples that does not satisfy the predicate. Also, it prints x when skip a sample
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
    for_all {x, y} in {int, list(int)} do
      result = Sample.push(x, y)
      Enum.at(result, 0) == x and Enum.count(result) == Enum.count(y) + 1
    end
  end

  # specify iteration count for running test
  @tag iterations: 30
  property :square_with_iteration_count do
    for_all x in int, do: x * x >= 0
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
 mix test test/sample_test.exs
..................................................................................................................................................................................................................xxx....x.xx..xxx.x.xx.xx..x...x..x..xx.xx..xx.xx.x..x.x..x..x......x.xx............x.x..x..x...xxx..x..x..xx.x..xx.xx.x......x.xxx.xx..xx.x.x.x.xx.x.xx......xx..xxxx..x....xxx.xxxxx.xxxxx..xx...........................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................

Finished in 0.2 seconds (0.1s on load, 0.08s on tests)
948 tests, 0 failures
```

You can also add the optional flag --trace to get additional output
```Shell
mix test test/sample_test.exs --trace

ExCheck.SampleTest
  * implies_property........xx.x.x..x..xx.xxx..x.x.x.x..x..x..xx....x.x.xx.xxxxxx..xx...x...xx.x...x.x..xxxxx..x...x......xxxxx.x.x..xxx.x..x.xx..xx..xxxx.x.x..xx.......x..xx.xx...x...x...xxx.xxx.x.xx.xx  * implies_property (14.7ms)
  * square_property........................................................................................................................................................................................  * square_property (4.1ms)
  * push_list_property.....................................................................................................................................................................................  * push_list_property (14.7ms)
  * square_with_iteration_count_property (0.7ms)......................
  * such_that_property.....................................................................................................................................................................................  * such_that_property (4.8ms)
  * concat_list_property...................................................................................................................................................................................  * concat_list_property (25.4ms)


Finished in 0.1 seconds (0.1s on load, 0.06s on tests)
942 tests, 0 failures
```


There are some more examples at <a href="https://github.com/parroty/excheck/tree/master/test" target="_blank">test</a> directory.

### Generators
The following generators defined in :triq are imported through "use ExCheck" statement.

- list/1, tuple/1, int/0, int/1, int/2, byte/0, real/0, sized/1, elements/1, any/0, atom/0, atom/1, choose/2, oneof/1, frequency/1, bool/0, char/0, return/1, vector/2, binary/1, binary/0, non_empty/1, resize/2, non_neg_integer/0, pos_integer/0,
- unicode_char/0, unicode_string/0, unicode_string/1, unicode_binary/0, unicode_binary/1, unicode_binary/2, unicode_characters/0, unicode_characters/1,
- bind/2, bindshrink/2, suchthat/2, pick/2, shrink/2, sample/1, sampleshrink/1, seal/1, open/1, peek/1, domain/3, shrink_without_duplicates/1


### Notes

- It's a trial implementation, and has limited functionalities yet.
- Files in test folder contains some more property examples.
